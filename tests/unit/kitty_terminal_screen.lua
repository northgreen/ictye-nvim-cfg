local MiniTest = require('mini.test')
local T = MiniTest.new_set()
local equal = MiniTest.expect.equality
local Screen = require('experimental.kitty_terminal.screen')
local Parser = require('experimental.kitty_terminal.parser')
local ESC = '\27'
local function terminal(cols, rows, opts, callbacks)
  local screen = Screen.new(cols or 10, rows or 3, opts)
  return screen, Parser.new(screen, callbacks)
end
local function lines(screen) return (screen:render()) end
local function csi(parser, body, final) parser:feed(ESC .. '[' .. body .. final) end

T['delayed wrap, CR/LF and backspace'] = function()
  local s, p = terminal(4, 2)
  p:feed('abcd'); equal(s.row, 1); equal(s.col, 4); equal(#s.history, 0)
  p:feed('\rZ'); equal(lines(s), { 'Zbcd', '    ' })
  p:feed('\nXY'); equal(lines(s), { 'Zbcd', ' XY ' })
  p:feed('\8!'); equal(lines(s)[2], ' X! ')
  p:feed('ab'); equal(lines(s), { 'Zbcd', ' X!a', 'b   ' }); equal(#s.history, 1)
end

T['UTF8, CJK and combining marks at every split'] = function()
  local input = 'A界é🙂Z'
  for split = 0, #input do
    local s, p = terminal(12, 2)
    p:feed(input:sub(1, split)); p:feed(input:sub(split + 1))
    equal(lines(s)[1], input .. '     ', { fail_reason = 'UTF8 split ' .. split })
    equal(s.grid[1][2].width, 2); equal(s.grid[1][3].width, 0)
    equal(s.grid[1][3].text, ''); equal(s.grid[1][4].text, 'é')
  end
  local s, p = terminal(4, 2)
  for index = 1, #input do p:feed(input:sub(index, index)) end
  equal(s.grid[1][4].text, 'é'); equal(lines(s)[2], '🙂Z ')
  local s2, p2 = terminal(4, 2)
  p2:feed('abc界'); equal(lines(s2), { 'abc ', '界  ' })
  p2:feed(ESC .. '[1;3HX'); equal(lines(s2)[1], 'abX ')
  p2:feed(ESC .. '[2;2HY'); equal(lines(s2)[2], ' Y  ', { fail_reason = 'overwriting continuation clears wide lead' })
end

T['fragmented CSI, SGR and byte highlight columns'] = function()
  local sequence = ESC .. '[1;3;4;7;9;38;2;12;34;56;48;5;200m界' .. ESC .. '[0mX'
  for split = 0, #sequence do
    local s, p = terminal(5, 2)
    p:feed(sequence:sub(1, split)); p:feed(sequence:sub(split + 1))
    equal(s.grid[1][1].attr, { bold = true, italic = true, underline = true, reverse = true,
      strikethrough = true, fg = '#0c2238', bg = 200 })
    equal(s.grid[1][3].attr, {})
    local _, spans = s:render()
    equal(spans[1], { row = 0, col = 0, end_col = 3, attr = s.grid[1][1].attr })
  end
  local s, p = terminal()
  p:feed(ESC .. '[91;104mA' .. ESC .. '[22;23;24;27;29;39;49mB')
  equal(s.grid[1][1].attr, { fg = 9, bg = 12 }); equal(s.grid[1][2].attr, {})
  p:feed(ESC .. '[31mC' .. ESC .. '[32mD'); equal(s.grid[1][3].attr.fg, 1)
  p:feed(ESC .. '[38:2::17:34:51;48:2:0:68:85:102mE')
  equal(s.grid[1][5].attr, { fg = '#112233', bg = '#445566' })
end

T['cursor addressing, origin and margins'] = function()
  local s, p = terminal(6, 5)
  csi(p, '2;4', 'r'); csi(p, '?6', 'h'); equal(s.row, 2)
  csi(p, '2;3', 'H'); equal({ s.row, s.col }, { 3, 3 })
  csi(p, '99', 'A'); equal(s.row, 2)
  csi(p, '99', 'B'); equal(s.row, 4)
  csi(p, '1;1', 'f'); equal({ s.row, s.col }, { 2, 1 })
  csi(p, '?6', 'l'); csi(p, '5', 'd'); csi(p, '4', 'G')
  equal({ s.row, s.col }, { 5, 4 })
  csi(p, '2', 'D'); csi(p, '1', 'A'); csi(p, '2', 'C')
  equal({ s.row, s.col }, { 4, 4 })
  csi(p, '', 'F'); equal({ s.row, s.col }, { 3, 1 })
  csi(p, '', 'E'); equal({ s.row, s.col }, { 4, 1 })
end

T['scroll region excludes history and keeps outside IDs'] = function()
  local s, p = terminal(3, 4)
  p:feed('111\r\n222\r\n333\r\n444')
  local first, last = s.grid[1].id, s.grid[4].id
  csi(p, '2;3', 'r'); csi(p, '3;1', 'H'); p:feed('\n')
  equal(lines(s), { '111', '333', '   ', '444' }); equal(#s.history, 0)
  equal(s.grid[1].id, first); equal(s.grid[4].id, last)
  csi(p, '', 'T'); equal(lines(s), { '111', '   ', '333', '444' })
  csi(p, '2;1', 'H'); p:feed(ESC .. 'M')
  equal(lines(s), { '111', '   ', '   ', '444' })
end

T['bounded history and stable row anchor IDs'] = function()
  local s, p = terminal(3, 2, { scrollback = 2 })
  local id = s:line_id()
  p:feed('one\r\ntwo\r\ntri')
  equal(s.history[1].id, id)
  local _, _, ids = s:render(); equal(ids[id], 1)
  p:feed('\r\nfou\r\nfiv'); equal(#s.history, 2)
  equal(lines(s), { 'two', 'tri', 'fou', 'fiv' })
  _, _, ids = s:render(); equal(ids[id], nil)
  csi(p, '3', 'J'); equal(#s.history, 0); equal(lines(s), { 'fou', 'fiv' })
end

T['EL and ED modes'] = function()
  for mode = 0, 2 do
    local s, p = terminal(4, 3)
    p:feed('abcd\r\nefgh\r\nijkl'); csi(p, '2;2', 'H'); csi(p, tostring(mode), 'K')
    local expected = { [0] = 'e   ', [1] = '  gh', [2] = '    ' }
    equal(lines(s)[2], expected[mode])
  end
  for mode = 0, 2 do
    local s, p = terminal(4, 3)
    p:feed('abcd\r\nefgh\r\nijkl'); csi(p, '2;2', 'H'); csi(p, tostring(mode), 'J')
    local expected = { [0] = { 'abcd', 'e   ', '    ' }, [1] = { '    ', '  gh', 'ijkl' },
      [2] = { '    ', '    ', '    ' } }
    equal(lines(s), expected[mode]); equal({ s.row, s.col }, { 2, 2 })
  end
end

T['character and line editing'] = function()
  local s, p = terminal(6, 3)
  p:feed('abcdef'); csi(p, '1;3', 'H'); csi(p, '2', '@'); equal(lines(s)[1], 'ab  cd')
  csi(p, '1', 'P'); equal(lines(s)[1], 'ab cd ')
  csi(p, '2', 'X'); equal(lines(s)[1], 'ab  d ')
  csi(p, '4', 'h'); p:feed('X'); equal(lines(s)[1], 'abX  d'); csi(p, '4', 'l')
  csi(p, '2;1', 'H'); p:feed('second'); csi(p, '3;1', 'H'); p:feed('third')
  csi(p, '2;1', 'H'); csi(p, '', 'L'); equal(lines(s), { 'abX  d', '      ', 'second' })
  csi(p, '', 'M'); equal(lines(s), { 'abX  d', 'second', '      ' })
  csi(p, '1;1', 'H'); csi(p, '', 'M'); equal(#s.history, 0, { fail_reason = 'delete line is not scrollback' })
  csi(p, '1;1', 'H'); p:feed('界界'); csi(p, '1;2', 'H'); csi(p, '', 'P')
  for col = 1, s.cols do
    if s.grid[1][col].width == 0 then equal(s.grid[1][col - 1].width, 2) end
  end
end

T['alternate screens preserve primary anchors and cursor'] = function()
  for _, mode in ipairs({ '47', '1047', '1049' }) do
    local s, p = terminal(5, 2)
    p:feed('main'); local id = s:line_id()
    csi(p, '?' .. mode, 'h'); equal(s.alt, true); equal(lines(s), { '     ', '     ' })
    p:feed('alternate\r\nmore\r\ntext'); equal(#s.history, 0)
    csi(p, '?' .. mode, 'l'); equal(s.alt, false)
    equal(lines(s), { 'main ', '     ' }); equal(s:line_id(), id); equal(s.col, 5)
  end
end

T['DEC save/restore, CSI save/restore and reset IDs'] = function()
  local s, p = terminal(5, 3)
  p:feed('abc' .. ESC .. '[31m' .. ESC .. '7' .. ESC .. '[3;1Hxyz' .. ESC .. '[0m' .. ESC .. '8Q')
  equal(lines(s), { 'abcQ ', '     ', 'xyz  ' }); equal(s.grid[1][4].attr.fg, 1)
  csi(p, '', 's'); csi(p, '2;1', 'H'); csi(p, '', 'u'); equal({ s.row, s.col }, { 1, 5 })
  local id = s:line_id(); p:feed(ESC .. 'c'); equal(lines(s), { '     ', '     ', '     ' })
  equal(s:line_id() > id, true); equal(s.modes.wrap, true)
end

T['47 preserves alternate contents, 1047 clears on exit, 1049 clears on entry'] = function()
  local s, p = terminal(5, 2)
  csi(p, '?47', 'h'); p:feed('saved'); local anchor = s:line_id()
  csi(p, '?47', 'l'); csi(p, '?47', 'h')
  equal(lines(s)[1], 'saved'); equal(s:line_id(), anchor)
  csi(p, '?1047', 'l'); csi(p, '?47', 'h'); equal(lines(s)[1], '     ')
  p:feed('other'); csi(p, '?47', 'l'); csi(p, '?1049', 'h'); equal(lines(s)[1], '     ')
end

T['tabs and cursor modes'] = function()
  local s, p = terminal(20, 2)
  p:feed('\tX'); equal(s.grid[1][9].text, 'X')
  csi(p, '3', 'g'); p:feed('\r\t'); equal(s.col, 20)
  csi(p, '4', 'G'); p:feed(ESC .. 'H\r\t'); equal(s.col, 4)
  p:feed(ESC .. '[?1;2004;1002;1006;25h'); equal(s.modes.app_cursor, true)
  equal(s.modes.bracketed_paste, true); equal(s.modes.mouse, 1002); equal(s.modes.mouse_sgr, true)
  csi(p, '?25', 'l'); equal(s.modes.cursor_visible, false)
  csi(p, '?7', 'l'); csi(p, '20', 'G'); p:feed('XYZ'); equal(lines(s)[1]:sub(-1), 'Z'); equal(s.row, 1)
end

T['resize dimensions, history IDs, wide-edge repair and alt restore'] = function()
  local s, p = terminal(5, 3)
  p:feed('one\r\ntwo\r\n界界')
  local first = s.grid[1].id
  s:resize(3, 2); equal({ s.cols, s.rows, s.row, s.col }, { 3, 2, 2, 3 })
  equal(s.history[1].id, first); equal(lines(s), { 'one', 'two', '界 ' })
  s:resize(7, 4); equal(lines(s), { 'one    ', 'two    ', '界     ', '       ', '       ' })
  csi(p, '?1049', 'h'); p:feed('alt'); s:resize(4, 2)
  equal({ #s.grid, #s.grid[1] }, { 2, 4 })
  csi(p, '?1049', 'l'); equal({ #s.grid, #s.grid[1] }, { 2, 4 })
  local _, _, ids = s:render(); equal(ids[first], 1)
  csi(p, '?1049', 'h'); csi(p, '2;1', 'H'); s:resize(4, 5)
  equal(s.bottom, 5); p:feed('\n\n\n'); equal(s.row, 5)
  csi(p, '?1049', 'l'); equal(s.bottom, 5)
  equal(pcall(function() s:resize(0, 2) end), false)
end

T['strings and callback interception at every possible byte split'] = function()
  local input = 'A' .. ESC .. ']2;title\7B' .. ESC .. '_Gm=1;AAAA' .. ESC .. '\\C'
    .. ESC .. 'Pqpayload\7bytes' .. ESC .. '\\D' .. ESC .. '[2JE'
  for split = 0, #input do
    local packets, requests, bells = {}, {}, 0
    local s, p = terminal(12, 2, nil, {
      string = function(kind, body, terminator) packets[#packets + 1] = { kind, body, terminator } end,
      csi = function(body, final) requests[#requests + 1] = { body, final }; return final == 'J' end,
      bell = function() bells = bells + 1 end,
    })
    p:feed(input:sub(1, split)); p:feed(input:sub(split + 1))
    equal(lines(s)[1], 'ABCDE       ')
    equal(packets, { { 'osc', '2;title', '\7' }, { 'apc', 'Gm=1;AAAA', ESC .. '\\' },
      { 'dcs', 'qpayload\7bytes', ESC .. '\\' } })
    equal(requests, { { '2', 'J' } }); equal(bells, 0)
    p:feed('\7'); equal(bells, 1)
  end
end

T['large payloads remain byte-exact and bounded overflow is explicit'] = function()
  local payload = 'Gf=100,m=1;' .. string.rep('aA9+/=', 200000)
  local result
  local _, p = terminal(4, 2, nil, { string = function(kind, body) result = { kind, body } end })
  local packet = ESC .. '_' .. payload .. ESC .. '\\'
  for pos = 1, #packet, 4093 do p:feed(packet:sub(pos, pos + 4092)) end
  equal(result, { 'apc', payload })
  local errors, packets = {}, {}
  local s, limited = terminal(4, 2, nil, { max_packet = 8,
    error = function(message, kind) errors[#errors + 1] = { message, kind } end,
    string = function(...) packets[#packets + 1] = { ... } end })
  limited:feed(ESC .. '_123456789' .. ESC .. '\\OK')
  equal(#errors, 1); equal(errors[1][2], 'apc'); equal(#packets, 0); equal(lines(s)[1], 'OK  ')
  limited:feed(ESC .. '[123456789mZ'); equal(#errors, 2); equal(errors[2][2], 'csi')
  equal(lines(s)[1], 'OKZ ')
  local _, strict = terminal(4, 2, nil, { max_packet = 2 })
  local ok, err = pcall(function() strict:feed(ESC .. ']abc') end)
  equal(ok, false); equal(tostring(err):find('packet exceeds 2 bytes', 1, true) ~= nil, true)
end

T['explicit cell widths and fragments of a mixed terminal stream'] = function()
  local s = Screen.new(8, 2)
  s:put('ABCD', 4); equal(s.col, 5); equal(s.grid[1][4].width, 0)
  s:csi('1;3', 'H'); s:write('Z'); equal(lines(s)[1], '  Z     ')
  local input = 'a界é' .. ESC .. '[31mR' .. ESC .. '[0m\r\n'
    .. ESC .. ']2;title\7' .. 'xy' .. ESC .. '[2D!' .. ESC .. '_Gm=1;chunk' .. ESC .. '\\'
    .. ESC .. '[?1049hALT' .. ESC .. '[?1049l' .. '\r\nlast'
  local expected_screen, expected_parser = terminal(8, 3)
  expected_parser:feed(input)
  for chunk_size = 1, #input do
    local actual, parser = terminal(8, 3)
    for pos = 1, #input, chunk_size do parser:feed(input:sub(pos, pos + chunk_size - 1)) end
    equal(actual.grid, expected_screen.grid, { fail_reason = 'chunk size ' .. chunk_size })
    equal({ actual.row, actual.col, actual.attr, actual.history },
      { expected_screen.row, expected_screen.col, expected_screen.attr, expected_screen.history })
  end
end

T['cancellation, ignored charset designation and malformed UTF8 recovery'] = function()
  local s, p = terminal(20, 2)
  p:feed('A' .. ESC .. '[31\24B' .. ESC .. ']hidden\26C' .. ESC .. '(BD' .. ESC .. ')0E')
  equal(lines(s)[1], 'ABCDE               ')
  p:feed(ESC .. '[31' .. ESC .. '[32mF'); equal(s.grid[1][6].attr.fg, 2)
  p:feed('\255G\226\rH'); equal(s.grid[1][1].text, 'H')
  equal(s.grid[1][7].text, '�'); equal(s.grid[1][8].text, 'G'); equal(s.grid[1][9].text, '�')
  local c1s, c1p = terminal(8, 2)
  local encoded = '\194\15531mR\194\1550mZ'
  for index = 1, #encoded do c1p:feed(encoded:sub(index, index)) end
  equal(lines(c1s)[1], 'RZ      '); equal(c1s.grid[1][1].attr.fg, 1)
end

return T
