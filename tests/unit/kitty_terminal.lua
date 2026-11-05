-- 原始 PTY 与原生 terminal 的集成用例各自运行在独立 Neovim，避免事件/窗口串扰。
local MiniTest = require('mini.test')
local child = MiniTest.new_child_neovim()
local resultfile
local T = MiniTest.new_set({ hooks = {
    pre_case = function()
        child.restart({ '-u', 'tests/minimal_init.lua' })
        resultfile = vim.fn.tempname()
        child.lua('resultfile = ...', {resultfile})
        child.lua([[
            Terminal = require('experimental.kitty_terminal')
            Render = require('experimental.kitty_terminal.render')
            Screen = require('experimental.kitty_terminal.screen')
            check = MiniTest.new_expectation('终端行为', function(value) return not not value end,
                function(_, message) return message end)
        ]])
    end,
    post_case = function()
        child.stop()
        vim.fn.delete(resultfile); vim.fn.delete(resultfile..'.tmp')
    end,
} })

T['RIS 重置后仍镜像原生显示'] = function()
    child.lua([[
        local mirrored = {}
        local term = {screen=Screen.new(10,3),display=function(_,s) mirrored[#mirrored+1]=s end}
        Render.attach(term)
        term.screen:escape('c'); term.screen:write('after-reset')
        MiniTest.expect.equality(mirrored, {'\27c','after-reset'})
    ]])
end

T['原点模式下图形光标落在正确原生单元格'] = function()
    child.lua([[
        local buf = vim.api.nvim_create_buf(false,true)
        vim.api.nvim_set_current_buf(buf)
        local channel = vim.api.nvim_open_term(buf,{})
        local term = setmetatable({screen=Screen.new(vim.o.columns,vim.api.nvim_win_get_height(0)),display_pending={}},
            {__index=Terminal.Term})
        Render.attach(term)
        term.screen:csi('5;10','r'); term.screen:csi('?6','h'); term.screen:csi('2;1','H')
        term.screen:control('\n'); term.screen.col=2; term:sync_cursor()
        vim.api.nvim_chan_send(channel,table.concat(term.display_pending)..'@')
        check(vim.wait(1000,function()
            local line=vim.api.nvim_buf_get_lines(buf,6,7,false)[1] or ''
            return line:sub(2,2)=='@'
        end,10),'原生标记应在绝对第7行、第2列')
    ]])
end

T['真实 PTY 同步回复查询并保留原生终端生命周期'] = function()
    child.lua([==[
        local original_paste = vim.paste
        local opened, closed = {}, {}
        vim.api.nvim_create_autocmd('TermOpen',{callback=function(ev) opened[ev.buf]=true end})
        vim.api.nvim_create_autocmd('TermClose',{callback=function(ev) closed[ev.buf]=true end})
        local python = [[import os,sys,tty,termios,fcntl,struct,time,select,json
 tty.setraw(0)
 time.sleep(0.15)
 kernel=struct.unpack('HHHH',fcntl.ioctl(0,termios.TIOCGWINSZ,b'\0'*8))
 queries=[b'\x1b[18t',b'\x1b[14t',b'\x1b[16t',b'\x1b[6n',b'\x1b[>1u\x1b[?u',b'\x1b[<1u\x1b[?u']
 replies=[]
 for query in queries:
  os.write(1,query)
  data=b''
  deadline=time.monotonic()+2
  while time.monotonic()<deadline:
   if select.select([0],[],[],0.05)[0]:
    data+=os.read(0,4096)
    if data[-1:] in (b't',b'R',b'u'):break
  replies.append(data.decode())
 os.write(1,b'\x1b[2J\x1b[H\x1b[31mRED\x1b[0m\r\nUTF8: \xc3\xa9\xe4\xb8\xad\r\n')
 open(sys.argv[1]+'.tmp','w').write(json.dumps({'kernel':kernel,'replies':replies}))
 os.replace(sys.argv[1]+'.tmp',sys.argv[1])
 data=os.read(0,4096)
 os.write(1,b'INPUT:'+data+b'\r\n')
 ]]
        local term = Terminal.open({cmd={'python3','-c',python:gsub('\n ','\n'),resultfile},
            capture=false,cell_width=10,cell_height=20,host_send=function() end})
        check(vim.api.nvim_get_chan_info(term.job).mode=='bytes','原始任务通道不能启用终端模拟')
        check(vim.bo[term.buf].buftype=='terminal' and vim.api.nvim_get_chan_info(term.view_channel).buf==term.buf,
            '显示必须使用真正的终端缓冲区和内部通道')
        check(term.view_channel~=term.job and vim.api.nvim_get_chan_info(term.view_channel).mode=='terminal',
            '显示通道与原始PTY任务必须分离')
        check(vim.paste==original_paste,'不能覆盖原生粘贴')
        check(opened[term.buf],'创建视图应触发TermOpen')
        check(vim.wait(8000,function() return vim.fn.filereadable(resultfile)==1 end,10),'查询客户端超时')
        local r=vim.json.decode(table.concat(vim.fn.readfile(resultfile),'\n'))
        MiniTest.expect.equality(r.kernel,{term.screen.rows,term.screen.cols,term.screen.cols*10,term.screen.rows*20})
        MiniTest.expect.equality(r.replies,{
            string.format('\27[8;%d;%dt',term.screen.rows,term.screen.cols),
            string.format('\27[4;%d;%dt',term.screen.rows*20,term.screen.cols*10),
            '\27[6;20;10t','\27[1;1R','\27[?1u','\27[?0u',
        })
        term:send('typed-input\r')
        check(vim.wait(3000,function() return term.exited end,10),'子进程收到输入后应退出')
        check(vim.wait(1000,function() return not term.render_pending end,10),'最终输出应刷新完成')
        MiniTest.expect.equality(term.exit_code,0)
        MiniTest.expect.equality(term.errors,{})
        check(closed[term.buf],'输出刷新后应触发TermClose')
        local lines=table.concat(vim.api.nvim_buf_get_lines(term.buf,0,-1,false),'\n')
        check(lines:find('RED',1,true) and lines:find('UTF8: é中',1,true),'原生终端应正确显示ANSI及Unicode')
        check(lines:find('INPUT:typed-input',1,true),'输入须到达PTY且输出返回终端')
        check(not lines:find('\27',1,true),'文本不能泄漏原始转义字节')
        local win=vim.api.nvim_get_current_win()
        vim.cmd('vsplit'); vim.api.nvim_win_set_width(win,25); vim.api.nvim_set_current_win(win)
        term:resize()
        MiniTest.expect.equality(term.screen.cols,vim.api.nvim_win_get_width(win))
        term:close()
        MiniTest.expect.equality(Terminal.sessions[term.buf],nil)
    ]==])
end

return T
