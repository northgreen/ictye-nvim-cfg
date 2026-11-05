-- 只负责原始 PTY 的内核尺寸，不参与解析或原生 terminal 显示；打开 slave 不读取 shell。
-- 内核 winsize 同时存行列和总像素；仅 jobresize 不足以满足 icat 启动时的尺寸探测。
local M = {}
local ok, ffi = pcall(require, 'ffi')
if ok then
    pcall(ffi.cdef, [[
        struct kitty_lua_winsize { unsigned short row, col, xpixel, ypixel; };
        int ioctl(int fd, unsigned long request, ...);
        int open(const char *pathname, int flags, ...);
        int close(int fd);
    ]])
end
local linux = ok and ffi.os == 'Linux'

function M.cell_size()
    -- 读取外层 TUI 的实际像素/行列比值；无 ioctl 数据时让控制器使用回退或配置值。
    if linux then
        local size = ffi.new('struct kitty_lua_winsize[1]')
        for _, fd in ipairs({ 1, 0, 2 }) do
            if ffi.C.ioctl(fd, 0x5413, size) == 0 then
                local s = size[0]
                if s.col > 0 and s.row > 0 and s.xpixel > 0 and s.ypixel > 0 then
                    return math.floor(s.xpixel / s.col), math.floor(s.ypixel / s.row), 'ioctl'
                end
            end
        end
    end
    -- 返回 query 仅表示未测得尺寸，不在这里发送查询或等待终端响应。
    return nil, nil, 'query'
end

function M.resize(job, cols, rows, cw, ch)
    -- jobresize 更新 Nvim 的 PTY 状态；随后 ioctl 补齐像素字段并触发内核尺寸更新。
    vim.fn.jobresize(job, cols, rows)
    if not linux then return false, 'pixel ioctl is implemented for Linux only' end
    local path = vim.api.nvim_get_chan_info(job).pty
    if not path or path == '' then return false, 'job has no PTY slave' end
    local fd = ffi.C.open(path, 0x102) -- O_RDWR | O_NOCTTY
    if fd < 0 then return false, 'cannot open PTY slave: errno ' .. ffi.errno() end
    local size = ffi.new('struct kitty_lua_winsize[1]')
    size[0].col, size[0].row = cols, rows
    size[0].xpixel, size[0].ypixel = math.min(cols * cw, 65535), math.min(rows * ch, 65535)
    local status = ffi.C.ioctl(fd, 0x5414, size)
    local err = ffi.errno()
    ffi.C.close(fd)
    return status == 0, status ~= 0 and ('TIOCSWINSZ: errno ' .. err) or nil
end
return M
