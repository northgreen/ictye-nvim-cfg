local MiniTest = require('mini.test')
local P = require('experimental.kitty_terminal.protocol')
local G = require('experimental.kitty_terminal.graphics')
local Input = require('experimental.kitty_terminal.input')
local ESC, ST = '\27', '\27\\'
local check = MiniTest.new_expectation(
    function(_, message) return message end,
    function(value) return value end,
    function(value) return 'Observed: ' .. vim.inspect(value) end
)
local term, sent, host, view, graphics, temporary_paths, original_getreg, original_getmousepos

local function new_term()
    local fixture = { screen = { cols = 50, rows = 20, row = 3, col = 4, modes = {}, history = {} },
        cell_width = 10, cell_height = 20, palette = {}, foreground = '#eeeeee', background = '#111111',
        errors = {}, stats = { graphics_replies = 0 }, row_ids = { [8] = 3 } }
    function fixture:send(seq) sent[#sent + 1] = seq end
    function fixture:host_send(seq) host[#host + 1] = seq end
    function fixture:refresh() end
    function fixture.screen:line_id() return 8 end
    function fixture.screen:control() self.row = self.row + 1 end
    function fixture:host_protocol(kind, body) host[#host + 1] = kind .. ':' .. body end
    fixture.graphics = G.new(fixture)
    graphics[#graphics + 1] = fixture.graphics
    return fixture
end

local function temporary_path()
    local path = vim.fn.tempname()
    temporary_paths[#temporary_paths + 1] = path
    return path
end

local function text_keys(text)
    local result = {}
    for _, code in ipairs(vim.fn.str2list(text, true)) do
        result[#result + 1] = ESC .. '[' .. code .. ';;' .. code .. 'u'
    end
    return table.concat(result)
end

local function place_image()
    term.graphics:request('a=T,i=7,p=2,f=24,s=4,v=2,c=4,r=2,C=1;AAAA')
    term.graphics:draw({ view })
    return term.graphics.images['i:7'].host
end

local T = MiniTest.new_set({ hooks = {
    pre_case = function()
        original_getreg, original_getmousepos = vim.fn.getreg, vim.fn.getmousepos
        sent, host, graphics, temporary_paths = {}, {}, {}, {}
        term = new_term()
        view = { win = 10, row = 5, col = 9, topline = 3, leftcol = 0, cols = 30, rows = 10 }
    end,
    post_case = function()
        vim.fn.getreg, vim.fn.getmousepos = original_getreg, original_getmousepos
        local errors = {}
        for _, instance in ipairs(graphics) do
            local ok, err = pcall(instance.close, instance)
            if not ok then errors[#errors + 1] = tostring(err) end
        end
        for _, path in ipairs(temporary_paths) do
            local ok, result = pcall(vim.fn.delete, path)
            if not ok or (result ~= 0 and vim.uv.fs_lstat(path) ~= nil) then
                errors[#errors + 1] = 'Failed to remove fixture: ' .. path
            end
        end
        MiniTest.expect.equality(errors, {})
    end,
} })

T['viewport queries and palette mirroring'] = function()
    check(P.csi(term, '14', 't') and sent[#sent] == ESC .. '[4;400;500t', 'pixel size belongs to child viewport')
    P.csi(term, '16', 't'); check(sent[#sent] == ESC .. '[6;20;10t', 'cell pixel dimensions')
    P.csi(term, '18', 't'); check(sent[#sent] == ESC .. '[8;20;50t', 'cell row/column dimensions')
    P.csi(term, '6', 'n'); check(sent[#sent] == ESC .. '[3;4R', 'CPR uses Lua cursor not outer Nvim cursor')
    term.screen.modes.origin,term.screen.top,term.screen.row=true,5,7
    P.csi(term,'6','n'); check(sent[#sent]==ESC..'[3;4R','origin-mode CPR is relative to scroll margin')
    term.screen.modes.origin,term.screen.top,term.screen.row=false,nil,3
    local display = {}
    term.display=function(_,bytes) display[#display+1]=bytes end
    P.string(term,'osc','4;1;#12ab34',ST)
    check(term.palette[1]=='#12ab34' and display[1]==ESC..']4;1;#12ab34'..ST,'palette changes mirror to the internal terminal')
    term.display=nil
end

T['keyboard negotiation and local capability queries'] = function()
    P.csi(term, '>1', 'u'); P.csi(term, '?', 'u')
    check(sent[#sent] == ESC .. '[?1u', 'keyboard flag query answered locally')
    P.csi(term, '<1', 'u'); P.csi(term, '?', 'u')
    check(sent[#sent] == ESC .. '[?0u', 'keyboard mode stack restored')
    P.csi(term, '>25', 'u')
    check(Input.encode('h', term) == ESC .. '[104;;104u', 'Kitty all-key reports include associated printable text')
    P.csi(term, '<1', 'u')
    P.string(term, 'dcs', '+q544e;436f', ST)
    check(sent[#sent - 1] == ESC .. 'P1+r544e=787465726d2d6b69747479' .. ST, 'XTGETTCAP returns encoded TERM')
    check(sent[#sent] == ESC .. 'P1+r436f=323536' .. ST, 'XTGETTCAP colors')
    P.string(term, 'osc', '11;?', ST)
    check(sent[#sent] == ESC .. ']11;rgb:1111/1111/1111' .. ST, 'background query is scoped')
end

T['application cursor, paste transactions, and clipboard permissions'] = function()
    term.screen.modes.app_cursor = true
    check(Input.encode(vim.api.nvim_replace_termcodes('<Up>', true, false, true), term) == ESC .. 'OA', 'application cursor keys')
    term.screen.modes.bracketed_paste = true
    Input.paste(term, 'hello\nworld')
    check(sent[#sent] == ESC .. '[200~hello\nworld' .. ESC .. '[201~', 'bracketed paste framing')
    Input.paste(term, 'one', 1); Input.paste(term, 'two', 2); Input.paste(term, 'three', 3)
    check(table.concat({sent[#sent-2],sent[#sent-1],sent[#sent]}) == ESC .. '[200~onetwothree' .. ESC .. '[201~',
        'three-phase paste is one bracketed-paste transaction')
    local original_getreg = vim.fn.getreg
    vim.fn.getreg = function() error('untrusted clipboard query must not read the host register') end
    P.string(term,'osc','52;c;?',ST)
    vim.fn.getreg = original_getreg
    check(sent[#sent] == ESC .. ']52;c;' .. ST and term.stats.clipboard_reads_denied == 1,
        'clipboard reads denied by default with an empty protocol response')
    term.options = {allow_clipboard_read=true}
    vim.fn.getreg = function() return {'synthetic','clipboard'} end
    P.string(term,'osc','52;c;?',ST)
    vim.fn.getreg = original_getreg
    term.options = nil
    check(sent[#sent] == ESC .. ']52;c;' .. vim.base64.encode('synthetic\nclipboard') .. ST,
        'explicitly trusted clipboard reads handle provider line-list output')
end

T['alternate-screen mouse ignores primary scrollback'] = function()
    local original_mouse = vim.fn.getmousepos
    vim.fn.getmousepos = function() return {winid=1,line=5,column=4} end
    term.screen.alt, term.screen.history, term.screen.modes.mouse = true, {{}, {}, {}}, 1003
    local mouse_packet = Input.encode(vim.api.nvim_replace_termcodes('<LeftMouse>',true,false,true),term)
    vim.fn.getmousepos = original_mouse
    check(mouse_packet == ESC .. '[<0;4;5M', 'alternate-screen mouse ignores primary scrollback history')
    term.screen.alt, term.screen.history, term.screen.modes.mouse = false, {}, false
end

T['enhanced text, controls, and fragmented Unicode'] = function()
    term.keyboard_flags = 25
    local before_input = #sent
    check(Input.terminal(term, 'hello-lua') == text_keys('hello-lua'), 'bulk ASCII encodes every key with associated text')
    check(Input.terminal(term, 'é猫😀') == text_keys('é猫😀'), 'UTF8 encodes each Unicode codepoint')
    check(#sent == before_input, 'terminal input returns bytes without sending')
    check(Input.terminal(term, '\3\17\0\28\31\t\r\127') == ESC .. '[99;5u' .. ESC .. '[113;5u'
        .. ESC .. '[32;5u' .. ESC .. '[92;5u' .. ESC .. '[95;5u' .. ESC .. '[9u' .. ESC .. '[13u' .. ESC .. '[127u',
        'baseline controls map to Kitty control modifiers without associated text')
    local unicode = 'é猫😀'
    local fragments = {}
    for i = 1, #unicode do fragments[#fragments + 1] = Input.terminal(term, unicode:sub(i, i)) end
    check(table.concat(fragments) == text_keys(unicode), 'UTF8 byte fragments are buffered')
end

T['ambiguous Escape and fragmented special keys'] = function()
    term.keyboard_flags = 25
    check(Input.terminal(term, ESC) == '', 'ambiguous Escape waits for continuation')
    check(Input.terminal(term, '') == ESC .. '[27u', 'timeout flush encodes standalone Escape')
    check(Input.terminal(term,ESC..'[')=='' and Input.terminal(term,'')==ESC..'[91;3u','Alt+[ flushes after ambiguity timeout')
    check(Input.terminal(term,ESC..'O')=='' and Input.terminal(term,'')==ESC..'[79;3u','Alt+O flushes after ambiguity timeout')
    check(Input.terminal(term, ESC .. 'x') == ESC .. '[120;3u', 'baseline Alt key retains modifier')
    local special = ESC .. '[1;5A' .. ESC .. '[H' .. ESC .. '[F' .. ESC .. '[15~' .. ESC .. '[24;2~'
    check(Input.terminal(term, special) == special, 'multiple CSI special keys preserve xterm modifiers')
    check(Input.terminal(term, ESC .. 'OA' .. ESC .. 'OP' .. ESC .. 'O1;5Q')
        == ESC .. '[A' .. ESC .. '[P' .. ESC .. '[1;5Q', 'SS3 cursor and function keys use enhanced CSI forms')
    for _, suffix in ipairs({'P', 'Q', 'R', 'S'}) do
        check(Input.terminal(term, ESC .. 'O') == '' and Input.terminal(term, suffix) == ESC .. '[' .. suffix,
            'fragmented SS3 function key ' .. suffix)
    end
    for _, number in ipairs({15, 17, 18, 19, 20, 21, 23, 24}) do
        local sequence = ESC .. '[' .. number .. ';5~'
        check(Input.terminal(term, sequence) == sequence, 'F5-F12 retains CSI modifier: ' .. number)
    end
    check(Input.terminal(term, ESC .. '[Z') == ESC .. '[9;2u', 'enhanced Shift-Tab')
    check(Input.terminal(term, ESC .. '[') == '' and Input.terminal(term, '1;') == ''
        and Input.terminal(term, '5A') == ESC .. '[1;5A', 'CSI fragmentation retains modifiers')
    check(Input.terminal(term, ESC .. '[I' .. ESC .. '[O') == ESC .. '[I' .. ESC .. '[O', 'focus events pass through')
end

T['native mouse packets translate cell coordinates to pixels'] = function()
    term.keyboard_flags = 25
    local original_terminal_mouse = vim.fn.getmousepos
    vim.fn.getmousepos = function() error('native input must not query mouse position') end
    term.screen.modes.mouse_pixel = true
    local pixel_mouse = Input.terminal(term, ESC .. '[<36;4;5M' .. ESC .. '[<0;1;1m')
    vim.fn.getmousepos = original_terminal_mouse
    check(pixel_mouse == ESC .. '[<36;35;90M' .. ESC .. '[<0;5;10m', 'SGR cell coordinates become pixel centers')
    term.screen.modes.mouse_pixel = false
    check(Input.terminal(term, ESC .. '[<0;4;5M') == ESC .. '[<0;4;5M', 'cell mouse coordinates pass through')
end

T['bracketed paste survives every split and resumes key encoding'] = function()
    term.keyboard_flags = 25
    local paste = ESC .. '[200~hello\n猫\3' .. ESC .. '[A' .. ESC .. '[201~'
    for split = 1, #paste - 1 do
        local result = Input.terminal(term, paste:sub(1, split)) .. Input.terminal(term, paste:sub(split + 1))
        check(result == paste, 'bracketed paste bypasses encoding at split ' .. split)
    end
    local fragments = {}
    for i = 1, #paste do fragments[#fragments + 1] = Input.terminal(term, paste:sub(i, i)) end
    check(table.concat(fragments) == paste, 'paste framing and payload survive single-byte fragments')
    check(Input.terminal(term, paste .. 'x') == paste .. text_keys('x'), 'typing after paste resumes Kitty encoding')
    check(Input.terminal(term, ESC .. '[200~' .. ESC .. '[20') == ESC .. '[200~'
        and Input.terminal(term, '') == '' and Input.terminal(term, '1~') == ESC .. '[201~',
        'timeout never flushes an incomplete paste terminator')
end

T['keyboard flag variants preserve baseline input'] = function()
    term.keyboard_flags = 8
    check(Input.terminal(term, 'a\3') == ESC .. '[97u' .. ESC .. '[99;5u', 'all-key mode without associated-text flag')
    term.keyboard_flags = 1
    check(Input.terminal(term, 'a\3') == 'a\3' and Input.terminal(term, ESC) == ''
        and Input.terminal(term, '') == ESC .. '[27u', 'disambiguation-only mode preserves text and encodes Escape')
    term.keyboard_flags = 0
    local baseline = 'hello猫\3' .. ESC .. 'OA' .. ESC .. 'OP' .. ESC .. '[1;5D'
    check(Input.terminal(term, baseline) == baseline, 'non-enhanced input stays verbatim')
    check(Input.terminal(term, ESC) == '' and Input.terminal(term, '') == ESC, 'baseline standalone Escape flush')
    term.keyboard_flags = nil
end

T['chunked uploads and replacement placements share synchronized frames'] = function()
    term.graphics:request('a=T,i=7,p=2,f=24,s=4,v=2,c=4,r=2,C=1,m=1;AAAA')
    local host_id = term.graphics.images['i:7'].host
    check(host_id ~= 7 and #host == 0 and term.graphics.upload.packets[1]:find('a=t',1,true),
        'incomplete upload is namespaced and buffered off the shared host stream')
    term.graphics:request('m=0;AAAA')
    local final_packet = ESC .. '_Gm=0;AAAA' .. ST
    check(term.graphics.uploads[1].bytes:sub(-#final_packet) == final_packet and #host==0,
        'completed upload stays queued until its matching placement frame')
    check(term.graphics.placements['i:7:2'] ~= nil, 'placement created on completion')
    term.graphics:draw({ view })
    check(host[#host]:find(ESC .. '[5;12H', 1, true) ~= nil, 'placement adds pane origin to own cursor')
    check(host[#host]:find(final_packet,1,true) and host[#host]:find('a=p',1,true),
        'image bytes and replacement placement are sent in one synchronized host frame')
    local placement_id=term.graphics.placements['i:7:2'].views[10].id
    local before_frame=#host
    term.graphics:draw({view},true)
    check(#host==before_frame+1 and not host[#host]:find('a=d',1,true), 'forced native repaint never removes a visible image')
    check(host[#host]:sub(1,8)==ESC..'[?2026h' and host[#host]:sub(-8)==ESC..'[?2026l', 'placement frame has bounded synchronized-update markers')
    before_frame=#host
    term.graphics:request('a=p,i=7,p=2,C=1,c=4,r=3')
    check(#host==before_frame and term.graphics.placements['i:7:2'].views[10].id==placement_id,
        'browser frame replacement preserves host placement without immediate deletion')
    term.graphics:draw({view},true)
    check(not host[#host]:find('a=d',1,true),'replacement placement updates in place')
end

T['clipping and host acknowledgments use child coordinates and IDs'] = function()
    local host_id = place_image()
    local geom = G._test.clipped({ col = 1, cols = 10, rows = 5, fields = {}, image = {width=100,height=100} },
        {row=4,col=8,topline=3,leftcol=0,cols=6,rows=4}, 1, 10, 20)
    check(geom and geom.y == 40 and geom.h == 60 and geom.c == 5 and geom.w == 50,
        'partially scrolled image is cropped in source pixels and viewport cells')
    G.response(ESC .. '_Gi=' .. host_id .. ';OK')
    check(sent[#sent] == ESC .. '_Gi=7,p=2;OK' .. ST, 'real host acknowledgment maps image and placement IDs')
end

T['single-axis graphics scaling preserves source pixel aspect ratio'] = function()
    term.graphics:request('a=t,i=18,s=640,v=480;AAAA')
    term.graphics:request('a=p,i=18,c=40,C=1')
    local p=term.graphics.placements['i:18:0']
    MiniTest.expect.equality({p.cols,p.rows,p.pixel_width,p.pixel_height},{40,15,400,300})
    local full={row=1,col=1,cols=100,rows=100,leftcol=0,topline=1}
    local g=G._test.clipped(p,full,3,10,20)
    MiniTest.expect.equality({g.c,g.r,g.w,g.h},{40,nil,640,480})
    term.graphics:request('a=p,i=18,r=15,C=1')
    p=term.graphics.placements['i:18:0']
    MiniTest.expect.equality({p.cols,p.rows,p.pixel_width,p.pixel_height},{40,15,400,300})
    g=G._test.clipped(p,full,3,10,20)
    MiniTest.expect.equality({g.c,g.r},{nil,15})
    term.graphics:request('a=p,i=18,c=40,r=20,C=1')
    p=term.graphics.placements['i:18:0']
    MiniTest.expect.equality({p.pixel_width,p.pixel_height},{400,300})
    term.graphics:request('a=p,i=18,c=20,w=0,h=0,x=320,y=240,C=1')
    p=term.graphics.placements['i:18:0']
    MiniTest.expect.equality({p.pixel_width,p.pixel_height},{200,150})
end

T['placement deletion preserves siblings and hiding removes host placements'] = function()
    place_image()
    term.graphics:request('a=p,i=7,p=3,C=1,c=2,r=2')
    term.graphics:request('a=d,d=I,i=7,p=2')
    check(term.graphics.images['i:7'] ~= nil and term.graphics.placements['i:7:3'] ~= nil,
        'uppercase placement deletion preserves sibling image data')
    term.graphics:request('a=d,d=I,i=9999999')
    check(term.graphics.images['i:7'] ~= nil, 'unknown image deletion never frees another child image')
    term.graphics:draw({})
    check(host[#host]:find('a=d', 1, true) ~= nil, 'hidden view deletes host placement')
end

T['file transport reads PNG metadata and rejects FIFOs without blocking'] = function()
    local png = temporary_path()
    -- Only the signature and IHDR dimensions are read by the metadata parser.
    local header = '\137PNG\r\n\26\n' .. '\0\0\0\13IHDR' .. '\0\0\0\4\0\0\0\2'
    local fd = assert(vim.uv.fs_open(png, 'w', 384))
    local written = vim.uv.fs_write(fd, header, 0)
    vim.uv.fs_close(fd)
    MiniTest.expect.equality(written, #header)
    local w, h = G._test.dimensions({ f = '100', t = 'f' }, vim.base64.encode(png))
    check(w == 4 and h == 2, 'read PNG dimensions through file transport')
    local fifo = temporary_path()
    check(vim.system({'mkfifo',fifo}):wait().code == 0, 'create FIFO regression fixture')
    local started = vim.uv.hrtime()
    local fw = G._test.dimensions({f='100',t='f'},vim.base64.encode(fifo))
    check(fw == nil and vim.uv.hrtime()-started < 1e9, 'FIFO graphic paths are rejected without blocking Nvim')
end

T['interleaved sessions flush complete uploads independently'] = function()
    local other = new_term()
    local before = #host
    term.graphics:request('a=t,i=11,m=1;AAAA')
    other.graphics:request('a=t,i=11,m=1;BBBB')
    check(#host == before, 'two incomplete images never reach the shared host stream')
    term.graphics:request('m=0;CCCC')
    other.graphics:request('m=0;DDDD')
    term.graphics:draw({view})
    other.graphics:draw({})
    check(#host == before + 2 and host[before+1]:find('AAAA',1,true) and host[before+1]:find('CCCC',1,true)
        and not host[before+1]:find('BBBB',1,true) and host[before+2]:find('BBBB',1,true),
        'interleaved sessions produce two noninterleaved complete host uploads')
    other.graphics:close()
end

T['deleted uploads stay retired and rebuilds flush deletion before replacement'] = function()
    term.graphics:request('a=T,i=12,q=2,C=1,c=1,r=1,s=1,v=1;AAAA')
    term.graphics:request('a=d,d=I,i=12')
    local before=#host
    term.graphics:draw({view})
    check(#host==before+1 and not host[#host]:find('a=t',1,true),
        'image deleted before frame flush is not uploaded or resurrected')
    term.graphics:request('a=T,i=13,C=1,c=1,r=1,s=1,v=1;AAAA')
    term.graphics:draw({view})
    before=#host
    term.graphics:request('a=d,d=I,i=13')
    term.graphics:request('a=T,i=13,C=1,c=1,r=1,s=1,v=1;BBBB')
    check(#host==before,'delete and rebuild keeps previous frame visible until replacement flush')
    term.graphics:draw({view})
    local deletion=host[#host]:find('a=d',1,true)
    local upload=host[#host]:find('a=t',1,true)
    check(#host==before+1 and deletion and upload and deletion<upload and host[#host]:find('a=p',1,true),
        'explicit deletion precedes replacement upload and placement within one synchronized frame')
    term.graphics:close()
    check(next(term.graphics.images) == nil, 'close releases host images')
end

T['quiet placement success cannot acknowledge shared memory upload early'] = function()
    term.graphics:request('a=t,i=6,q=0,s=1,v=1;AAAA')
    local image = term.graphics.images['i:6']
    term.graphics:request('a=p,i=6,p=1,q=1,C=1,c=1,r=1')
    MiniTest.expect.equality(sent,{})
    term.graphics:draw({view})
    check(G.response(ESC .. '_Gi=' .. image.host .. ';OK' .. ST), 'host upload reply routed')
    MiniTest.expect.equality(sent,{ESC .. '_Gi=6;OK' .. ST})
    term.graphics:request('a=p,i=999,q=1')
    check(sent[#sent]:find('ENOTSUP',1,true),'q=1 must still report errors')
    term.graphics:request('a=q,i=33,q=1,f=32')
    check(not sent[#sent]:find('i=33',1,true),'q=1 suppresses successful query replies')
end

T['deleted in-flight frame retains upload acknowledgement until completion'] = function()
    term.graphics:request('a=t,i=6,q=0,s=1,v=1;AAAA')
    local image = term.graphics.images['i:6']
    term.graphics:request('a=d,d=I,i=6')
    term.graphics:draw({view})
    local bytes = host[#host]
    check(bytes:find('a=t',1,true) and not bytes:find('a=p',1,true), 'retired upload completes without placement')
    check(bytes:find('a=t',1,true) < bytes:find('a=d',bytes:find('a=t',1,true),true),
        'retired resource is freed after its upload')
    check(G.response(ESC .. '_Gi=' .. image.host .. ';OK' .. ST),'deleted image still has an upload owner')
    MiniTest.expect.equality(sent,{ESC .. '_Gi=6;OK' .. ST})
    MiniTest.expect.equality(term.graphics.host_images[image.host],nil)
    MiniTest.expect.equality(G.response(ESC .. '_Gi=' .. image.host .. ';OK' .. ST),false)
end

T['each upload keeps its own quiet level and placement reply identity'] = function()
    term.graphics:request('a=t,i=20,p=1,q=0,s=1,v=1;AAAA')
    local image=term.graphics.images['i:20']
    term.graphics:request('a=t,i=20,p=2,q=2,s=1,v=1;BBBB')
    term.graphics:draw({})
    G.response(ESC .. '_Gi=' .. image.host .. ';OK' .. ST)
    MiniTest.expect.equality(sent,{ESC .. '_Gi=20,p=1;OK' .. ST})
    sent={}
    term.graphics:request('a=t,i=20,p=3,q=0,s=1,v=1;CCCC')
    term.graphics:request('a=t,i=20,p=4,q=0,s=1,v=1;DDDD')
    term.graphics:request('a=t,i=20,p=5,q=1,s=1,v=1;EEEE')
    term.graphics:request('a=t,i=20,p=6,q=1,s=1,v=1;FFFF')
    term.graphics:draw({})
    for _, message in ipairs({'OK','OK','OK','EBADF:fixture'}) do
        G.response(ESC .. '_Gi=' .. image.host .. ';' .. message .. ST)
    end
    MiniTest.expect.equality(sent,{ESC .. '_Gi=20,p=3;OK' .. ST,
        ESC .. '_Gi=20,p=4;OK' .. ST,ESC .. '_Gi=20,p=6;EBADF:fixture' .. ST})
end

return T
