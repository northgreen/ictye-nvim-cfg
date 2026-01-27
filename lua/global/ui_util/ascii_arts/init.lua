local M = {}

M.each = {}

local function marge_each(t)
    for _,i in ipairs(t)do
        M.each[#M.each+1] = i
    end
end

local miku = require "global.ui_util.ascii_arts.miku"
local ictye_logo = require "global.ui_util.ascii_arts.ictye_logo"

M.miku = miku
marge_each(miku)

M.ictye_logo = ictye_logo
marge_each(ictye_logo)



return M

