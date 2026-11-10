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
            ESC, ST = '\27', '\27\\'
            sent, warnings = {}, {}
            vim.api.nvim_ui_send = function(seq) sent[#sent+1]=seq end
            vim.notify = function(msg) warnings[#warnings+1]=msg end
            bridge = require('experimental.kitty_test')
            t = bridge._test
            check = MiniTest.new_expectation('桥接行为', function(value) return not not value end,
                function(_,message) return message end)
            function contains(value,fragment) return value:find(fragment,1,true)~=nil end
            function event(buf,seq,cursor,terminator)
                t.request({buf=buf,data={sequence=seq,cursor=cursor or {1,0},terminator=terminator or ST}})
            end
            function reset() sent={} end
            function source()
                vim.cmd('enew')
                buf=vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_lines(buf,0,-1,false,{'one','two','three','four','five'})
                vim.cmd('vsplit')
                source_win=vim.api.nvim_get_current_win()
                vim.wo.number=true; vim.wo.signcolumn='yes:2'; vim.cmd('redraw')
                expected=vim.fn.screenpos(source_win,2,3)
                vim.cmd('wincmd l'); vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false,true))
                vim.cmd('redraw'); pos=t.source_position(buf,{2,2})
            end
            function upload()
                event(buf,ESC..'_Ga=T,i=9,p=2,c=3,r=2,m=1;YWJj',{2,2})
                for _,p in pairs(t.states[buf].placements) do placement=p end
                event(buf,ESC..'_Gm=0;ZGVm',{2,2})
            end
        ]])
    end,
    post_case = function()
      child.stop()
      vim.fn.delete(resultfile)
      vim.fn.delete(resultfile .. ".tmp")
    end,
  },
})

T["图形分帧及 tmux 转义保留原始载荷"] = function()
  child.lua([[
        local fields,controls,payload=t.graphics(ESC..'_Ga=t,f=24,m=1;YWJj')
        check(fields.a=='t' and fields.m=='1' and payload=='YWJj','不能截去载荷字节')
        MiniTest.expect.equality(t.packet(controls,payload,{i='123'}),ESC..'_Ga=t,f=24,m=1,i=123;YWJj'..ST)
        vim.env.TMUX='test'
        MiniTest.expect.equality(t.wrap_tmux(ESC..'_Gx'..ST),ESC..'Ptmux;'..ESC..ESC..'_Gx'..ESC..ESC..'\\'..ST)
    ]])
end

T["源分屏定位、分块及 UTF8 字节列转换"] = function()
  child.lua([[
        source()
        check(pos and pos.row==expected.row and pos.col==expected.col and pos.win==source_win,
            '位置必须跟随含行号和符号栏的源分屏')
        reset(); event(buf,ESC..'_Ga=q,i=7,f=24,s=1,v=1;AAAA')
        check(#sent==1 and contains(sent[1],'a=q') and contains(sent[1],';AAAA'..ST),'查询不能改成显示操作')
        local host_id=t.states[buf].images['7']
        check(host_id~=7 and contains(sent[1],'i='..host_id),'图片ID必须隔离')
        reset(); event(buf,ESC..'_Ga=T,i=9,p=2,c=3,r=2,m=1;YWJj',{2,2})
        check(#sent==1 and contains(sent[1],'a=t') and contains(sent[1],'m=1') and contains(sent[1],'C=1'),
            '上传必须与按分屏定位的放置分离')
        for _,p in pairs(t.states[buf].placements) do placement=p end
        check(placement and not placement.visible,'未完成上传不能重绘')
        reset(); event(buf,ESC..'_Gm=0;ZGVm',{2,2})
        check(#sent==2 and sent[1]==ESC..'_Gm=0;ZGVm'..ST and placement.visible,'续包元数据保持不变')
        check(contains(sent[2],string.format(ESC..'[%d;%dH',pos.row,pos.col)),'图形必须使用源分屏绝对坐标')
        check(sent[2]:sub(1,2)==ESC..'7' and sent[2]:sub(-2)==ESC..'8','保存并恢复宿主光标')
        vim.api.nvim_buf_set_lines(buf,4,5,false,{'é中abc'})
        local byte,extra=t.cell_to_byte(buf,5,3)
        check(byte==#'é中' and extra==0,'单元格列转UTF8字节列')
        local unicode=t.source_position(buf,{5,3})
        check(unicode and unicode.col==vim.fn.screenpos(source_win,5,#'é中'+1).col,'宽字符前缀保持位置')
        byte,extra=t.cell_to_byte(buf,5,8)
        check(byte==#'é中abc' and extra==2,'行尾后的空白列不能丢失')
        local other=vim.api.nvim_create_buf(false,true)
        event(other,ESC..'_Ga=q,i=7,f=24,s=1,v=1;AAAA')
        check(t.states[other].images['7']~=host_id,'跨缓冲区相同子ID不能碰撞')
        t.cleanup(other)
        reset(); event(buf,ESC..'_Ga=p,i=9,p=99,c=99999,r=2',{2,2})
        check(#sent==0,'越界图片不能覆盖其他分屏')
        reset(); vim.api.nvim_buf_set_lines(buf,0,0,false,{'inserted line'}); vim.cmd('redraw'); t.refresh()
        check(placement.row==pos.row+1 and placement.visible,'行移动后图片跟随锚点')
    ]])
end

T["隐藏恢复和按 placement 删除不影响共享图片"] = function()
  child.lua([[
        source(); upload(); reset()
        event(buf,ESC..'_Ga=d,d=z,z=3')
        check(#sent==0 and #warnings==1 and placement.visible,'不支持的删除显式失败且不删除图片')
        reset(); event(buf,ESC..'_Ga=T,i=10,p=2,c=3,r=2,m=1;YWJj',{2,2})
        local hidden_upload=t.states[buf].upload.placement
        reset(); vim.api.nvim_win_close(source_win,true)
        vim.wait(100,function() return not placement.visible end)
        check(not placement.visible and #sent>0 and contains(sent[1],'a=d,d=i'),'隐藏仅移除所属放置')
        reset(); event(buf,ESC..'_Gm=0;ZGVm',{2,2})
        check(#sent==1 and sent[1]==ESC..'_Gm=0;ZGVm'..ST and not hidden_upload.visible,
            '上传中隐藏后续包不能画到其他窗口')
        reset(); event(buf,ESC..'_Ga=p,i=9,p=3,c=3,r=2',{2,2})
        check(#sent==0,'隐藏源不能使用当前无关窗口光标')
        vim.api.nvim_set_current_buf(buf); vim.cmd('redraw'); reset(); t.refresh()
        check(#sent>0 and contains(sent[#sent],'a=p'),'恢复显示只重放放置而不重传图片')
        local shared=t.states[buf].images['9']
        reset(); event(buf,ESC..'_Ga=d,d=I,i=9,p=3')
        check(t.states[buf].images['9']==shared and t.states[buf].placements[tostring(shared)..':2']~=nil
            and t.states[buf].placements[tostring(shared)..':3']==nil,'按placement删除须保留共享图片及同胞')
        for _,seq in ipairs(sent) do check(not contains(seq,'d=I,i='..shared),'不能释放存活同胞使用的图片') end
    ]])
end

T["OSC 与 DCS 路由、清理及重复安装"] = function()
  child.lua([[
        local buf=vim.api.nvim_create_buf(false,true)
        event(buf,ESC..']99;i=kitty-test;hello',nil,'\7')
        MiniTest.expect.equality(sent,{ESC..']99;i=kitty-test;hello\7'})
        reset(); event(buf,ESC..'P@kitty-cmd{"cmd":"ls"}')
        MiniTest.expect.equality(sent,{ESC..'P@kitty-cmd{"cmd":"ls"}'..ST})
        reset(); event(buf,ESC..']7;file://host/path'); MiniTest.expect.equality(sent,{})
        local other=vim.api.nvim_create_buf(false,true)
        event(other,ESC..']99;i=osc-only;hello')
        check(t.routes()['99'][other]~=nil,'纯OSC请求须登记归属')
        t.cleanup(other); MiniTest.expect.equality(t.routes()['99'][other],nil)
        bridge.setup()
        MiniTest.expect.equality(#vim.api.nvim_get_autocmds({group='kitty_term_passthrough',event='TermRequest'}),1)
        bridge.stop(); MiniTest.expect.equality(t.states,{})
        MiniTest.expect.equality(t.routes(),{})
    ]])
end

T["真实 PTY 的 TermRequest 与响应 ID 还原"] = function()
  child.lua([==[
        vim.cmd('enew')
        local buf=vim.api.nvim_get_current_buf()
        local python=[[import os,tty,time,select,json,sys
 tty.setraw(0)
 os.write(1,b'\x1b_Ga=q,i=31,f=24,s=1,v=1;AAAA\x1b\\')
 data=b''
 deadline=time.monotonic()+3
 while time.monotonic()<deadline:
  if select.select([0],[],[],0.1)[0]:
   data+=os.read(0,4096)
   if b'\x1b\\' in data: break
 open(sys.argv[1]+'.tmp','w').write(json.dumps(list(data)))
 os.replace(sys.argv[1]+'.tmp',sys.argv[1])
 time.sleep(0.1)
 ]]
        local job=vim.fn.jobstart({'python3','-c',python:gsub('\n ','\n'),resultfile},{term=true})
        check(vim.wait(2000,function() return t.states[buf] and t.states[buf].images['31']~=nil end,10),
            '真实子进程应触发TermRequest，不依赖不存在的type字段')
        local host=t.states[buf].images['31']
        vim.api.nvim_exec_autocmds('TermResponse',{data={sequence=ESC..'_Gi='..host..';OK'..ST}})
        check(vim.wait(2000,function() return vim.fn.filereadable(resultfile)==1 end,10),'宿主响应应回到源PTY')
        local bytes=vim.json.decode(table.concat(vim.fn.readfile(resultfile),'\n'))
        MiniTest.expect.equality(string.char(unpack(bytes)),ESC..'_Gi=31;OK'..ST)
        vim.fn.jobstop(job)
    ]==])
end

return T
