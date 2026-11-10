-- 原始 PTY 与原生 terminal 的集成用例各自运行在独立 Neovim，避免事件/窗口串扰。
local MiniTest = require("mini.test")
local child = MiniTest.new_child_neovim()
local resultfile
local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.restart({ "-u", "tests/minimal_init.lua" })
      resultfile = vim.fn.tempname()
      child.lua("resultfile = ...", { resultfile })
      child.lua([[
            Terminal = require('experimental.kitty_terminal')
            Render = require('experimental.kitty_terminal.render')
            Screen = require('experimental.kitty_terminal.screen')
            vim.env.KITTY_LISTEN_ON = nil
            check = MiniTest.new_expectation('终端行为', function(value) return not not value end,
                function(_, message) return message end)
        ]])
    end,
    post_case = function()
      child.stop()
      vim.fn.delete(resultfile)
      vim.fn.delete(resultfile .. ".tmp")
    end,
  },
})

T["RIS 重置后仍镜像原生显示"] = function()
  child.lua([[
        local mirrored = {}
        local term = {screen=Screen.new(10,3),display=function(_,s) mirrored[#mirrored+1]=s end}
        Render.attach(term)
        term.screen:escape('c'); term.screen:write('after-reset')
        MiniTest.expect.equality(mirrored, {'\27c','after-reset'})
    ]])
end

T["真实键盘通道保留按下重复松开与分片并清空挂起按键"] = function()
  child.lua([[
        local Input = require('experimental.kitty_terminal.input')
        local term = {}
        local bytes = '\27[1;1A\27[122;1;122u\27[122;1:2;122u\27[57441;2u'
        local output = {}
        for i=1,#bytes do output[#output+1] = Input.raw(term,bytes:sub(i,i)) end
        MiniTest.expect.equality(table.concat(output),bytes)
        local released = '\27[1;1:3A\27[122;1:3u'
        MiniTest.expect.equality(Input.raw(term,released),released)
        MiniTest.expect.equality(Input.release(term),'\27[57441;2:3u')
        MiniTest.expect.equality(Input.release(term),'')
        Input.raw(term,'\27[92;5u\27[92;5:3u')
        local text, leave = Input.raw(term,'\27[110;5u')
        MiniTest.expect.equality(text,'')
        MiniTest.expect.equality(leave,true)
    ]])
end

T["真实键盘 flags3 保留普通文本 UTF8 与控制字节"] = function()
  child.lua([[
        local Input = require('experimental.kitty_terminal.input')
        local term = {keyboard_flags=3}
        local bytes = 'xé中\t\r\3'
        local output = {}
        for i=1,#bytes do output[#output+1] = Input.raw(term,bytes:sub(i,i)) end
        MiniTest.expect.equality(table.concat(output),bytes)
        MiniTest.expect.equality(Input.release(term),'')
    ]])
end

T["真实键盘粘贴不解析伪按键与退出组合且保留分片边界"] = function()
  child.lua([[
        local Input = require('experimental.kitty_terminal.input')
        local bytes = '\27[200~xé中\27[A\27[92;5u\27[110;5u\28\14\27[201~'
        for _, fragmented in ipairs({false,true}) do
            local term = {keyboard_flags=3}
            local output = {}
            local step = fragmented and 1 or #bytes
            for i=1,#bytes,step do
                local text, leave = Input.raw(term,bytes:sub(i,i+step-1))
                output[#output+1] = text
                MiniTest.expect.equality(leave,false)
            end
            MiniTest.expect.equality(table.concat(output),bytes)
            MiniTest.expect.equality(Input.release(term),'')
        end
    ]])
end

T["未修饰 Up 原样转发且失焦释放"] = function()
  child.lua([[
        local Input = require('experimental.kitty_terminal.input')
        local HostInput = require('experimental.kitty_terminal.host_input')
        local sent = {}
        local term = {keyboard_flags=3,screen={modes={}},send=function(_,bytes) sent[#sent+1]=bytes end}
        MiniTest.expect.equality(Input.raw(term,'\27[A'),'\27[A')
        HostInput.focus(term,false)
        MiniTest.expect.equality(sent,{'\27[1;1:3A'})
        MiniTest.expect.equality(Input.release(term),'')
    ]])
end

T["通道 EOF 关闭先释放按键再降级且销毁时仅清空状态"] = function()
  child.lua([[
        local Input = require('experimental.kitty_terminal.input')
        local HostInput = require('experimental.kitty_terminal.host_input')
        for _, lifecycle in ipairs({'active','closed','exited'}) do
            local sent = {}
            local term = {keyboard_requested=3,keyboard_flags=3,
                host_input={ready=true,captured=true,capture_wanted=true},
                send=function(self,bytes)
                    MiniTest.expect.equality(self.keyboard_flags,3)
                    MiniTest.expect.equality(self.host_input.closed,nil)
                    sent[#sent+1]=bytes
                end}
            if lifecycle ~= 'active' then term[lifecycle]=true end
            Input.raw(term,'\27[120;1u')
            HostInput.close(term)
            MiniTest.expect.equality(sent,lifecycle=='active' and {'\27[120;1:3u'} or {})
            MiniTest.expect.equality(term.keyboard_flags,1)
            MiniTest.expect.equality(term.host_input.closed,true)
            MiniTest.expect.equality(term.host_input.captured,false)
            MiniTest.expect.equality(term._raw_input,nil)
            HostInput.close(term)
        end
    ]])
end

T["缺少真实通道时不能宣称支持松键且协议栈恢复请求值"] = function()
  child.lua([[
        local term = Terminal.open({cmd={'/bin/sh','-c','read line'},capture=false,host_send=function() end})
        local replies = {}
        term.send = function(_,s) replies[#replies+1] = s end
        term:feed('\27[>11u\27[?u')
        MiniTest.expect.equality(term.keyboard_requested,11)
        MiniTest.expect.equality(term.keyboard_flags,9)
        MiniTest.expect.equality(replies,{'\27[?9u'})
        check(term.keyboard_error,'缺少通道应有明确错误')
        term:feed('\27[>25u\27[<u')
        MiniTest.expect.equality(term.keyboard_requested,11)
        MiniTest.expect.equality(term.keyboard_flags,9)
        term:close()
    ]])
end

T["宿主图形原点与原生窗口内容坐标一致"] = function()
  child.lua([[
        local buf = vim.api.nvim_create_buf(false,true)
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_buf_set_lines(buf,0,-1,false,{'origin'})
        local function check_origin(win)
            vim.cmd('redraw')
            local origin = vim.fn.screenpos(win,1,1)
            for _, view in ipairs(Render.views({buf=buf})) do
                if view.win == win then
                    MiniTest.expect.equality({view.row,view.col},{origin.row,origin.col})
                    return
                end
            end
            error('窗口视图缺失')
        end
        check_origin(vim.api.nvim_get_current_win())
        for _, border in ipairs({'none','rounded',{'','','','│','','','','│'}}) do
            local win = vim.api.nvim_open_win(buf,true,{relative='editor',row=2,col=3,
                width=40,height=8,border=border,style='minimal'})
            check_origin(win)
            vim.api.nvim_win_close(win,true)
        end
    ]])
end

T["宿主配色读取固定窗口并拒绝错误或不完整的响应"] = function()
  child.lua([[
        local Colors = require('experimental.kitty_terminal.colors')
        MiniTest.expect.equality(Colors.read(),nil)
        vim.env.KITTY_LISTEN_ON, vim.env.KITTY_WINDOW_ID = 'unix:/test-kitty','42'
        vim.fn.executable = function() return 1 end
        local response = {code=0,stdout='foreground #abcdef\nbackground #123456\ncursor #fedcba\ncolor0 #001122\ncolor255 #ffeedd\n'}
        vim.system = function(args)
            MiniTest.expect.equality(args,{'kitten','@','--to','unix:/test-kitty','get-colors','--match','id:42'})
            return {wait=function(_,timeout)
                MiniTest.expect.equality(timeout,500)
                return response
            end}
        end
        MiniTest.expect.equality(Colors.read(),{foreground='#abcdef',background='#123456',cursor='#fedcba',
            palette={[0]='#001122',[255]='#ffeedd'}})
        response = {code=124,stderr='timeout'}
        local colors, err = Colors.read()
        MiniTest.expect.equality(colors,nil)
        check(err:find('timeout',1,true),'查询失败须保留原因')
        response = {code=0,stdout='foreground #abcdef\nbackground invalid'}
        colors, err = Colors.read()
        MiniTest.expect.equality(colors,nil)
        check(err:find('missing',1,true),'不能应用不完整的宿主配色')
    ]])
end

T["宿主配色应用于局部显示与子进程查询且不修改全局主题"] = function()
  child.lua([[
        local normal = vim.api.nvim_get_hl(0,{name='Normal',link=false})
        local colors = {foreground='#abcdef',background='#123456',cursor='#fedcba',palette={[1]='#654321'}}
        local term = Terminal.open({cmd={vim.o.shell,'-c','read reply'},capture=false,colors=colors,
            host_send=function() end})
        local ns = vim.api.nvim_get_hl_ns({winid=vim.api.nvim_get_current_win()})
        local highlights = vim.api.nvim_get_hl(ns,{})
        for _, name in ipairs({'Normal','NormalFloat','FloatBorder','EndOfBuffer'}) do
            local hl = highlights[name]
            MiniTest.expect.equality({hl.fg,hl.bg},{0xabcdef,0x123456})
        end
        MiniTest.expect.equality(vim.api.nvim_get_hl(0,{name='Normal',link=false}),normal)
        MiniTest.expect.equality(vim.b[term.buf].terminal_color_1,'#654321')
        local replies = {}
        term.send = function(_,bytes) replies[#replies+1] = bytes end
        term:feed('\27]10;?\27\\\27]11;?\27\\\27]12;?\27\\\27]4;1;?\27\\')
        MiniTest.expect.equality(replies,{
            '\27]10;rgb:abab/cdcd/efef\27\\','\27]11;rgb:1212/3434/5656\27\\',
            '\27]12;rgb:fefe/dcdc/baba\27\\','\27]4;1;rgb:6565/4343/2121\27\\',
        })
        term:feed('\27[31mred\27[0m')
        check(table.concat(term.display_pending):find('\27[0;38;2;101;67;33m',1,true),
            'ANSI 索引色应使用宿主调色板转为真实 RGB')
        MiniTest.expect.equality(colors.palette,{[1]='#654321'})
        term:close()
    ]])
end

T["原点模式下图形光标落在正确原生单元格"] = function()
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

T["真实 PTY 同步回复查询并保留原生终端生命周期"] = function()
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

T["浮动终端使用 Kitty PTY 并在命令退出后关闭"] = function()
  child.lua([[
        local original_win = vim.api.nvim_get_current_win()
        require('global.ui_util.ui.float_term')('printf FLOAT_READY; read reply; printf "%s" "$reply"',
            {width=40,height=8,col=3,row=2})
        local win = vim.api.nvim_get_current_win()
        local term = Terminal.current()
        check(term ~= nil, '浮窗必须注册 Kitty 会话')
        local config = vim.api.nvim_win_get_config(win)
        MiniTest.expect.equality({config.relative,config.width,config.height,config.col,config.row},
            {'editor',40,8,3,2})
        MiniTest.expect.equality({term.screen.cols,term.screen.rows},{40,8})
        vim.cmd('redraw')
        local origin = vim.fn.screenpos(win,1,1)
        local view = Render.views(term)[1]
        MiniTest.expect.equality({view.row,view.col},{origin.row,origin.col})
        MiniTest.expect.equality(vim.api.nvim_get_chan_info(term.job).mode,'bytes')
        check(vim.wait(3000,function()
            return table.concat(vim.api.nvim_buf_get_lines(term.buf,0,-1,false),'\n'):find('FLOAT_READY',1,true)
        end,10),'真实子进程输出应显示在浮窗中')
        term:send('float-input\r')
        check(vim.wait(3000,function() return not vim.api.nvim_win_is_valid(win) end,10),
            '子进程退出应关闭浮窗')
        MiniTest.expect.equality(term.exit_code,0)
        MiniTest.expect.equality(term.errors,{})
        MiniTest.expect.equality(Terminal.sessions[term.buf],nil)
        MiniTest.expect.equality(vim.api.nvim_buf_is_valid(term.buf),false)
        MiniTest.expect.equality(vim.api.nvim_get_current_win(),original_win)
    ]])
end

T["手动关闭浮动终端会释放 Kitty 会话和子进程"] = function()
  child.lua([[
        require('global.ui_util.ui.float_term')({vim.o.shell,'-c','read reply'}, {width=40,height=8})
        local term = Terminal.current()
        vim.api.nvim_win_close(0,true)
        check(vim.wait(3000,function() return vim.fn.jobwait({term.job},0)[1] ~= -1 end,10),
            '关闭浮窗后子进程不能残留')
        MiniTest.expect.equality(term.closed,true)
        MiniTest.expect.equality(Terminal.sessions[term.buf],nil)
        MiniTest.expect.equality(vim.api.nvim_buf_is_valid(term.buf),false)
    ]])
end

return T
