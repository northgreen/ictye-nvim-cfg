local M = {}

M.name_to_avante = {
  ["openai-completions"] = "openai",
}

-- 原文密钥注入的环境变量名 -> 密钥。avante 只接受环境变量名或 cmd: 命令，
-- 原文密钥只能通过一个随机命名的环境变量传给它。
local injected = {}

--- 把原文密钥写入随机命名的环境变量，并返回变量名。
--- 同名变量不会重复注入；每次启动都会生成新的名字，避免与用户环境撞车。
--- @param secret string 原文密钥
--- @return string 注入密钥的环境变量名
function M.export_secret(secret)
  for name, value in pairs(injected) do
    if value == secret then
      return name
    end
  end
  local name
  repeat
    name = "AVANTE_SECRET_" .. string.upper(string.format("%08x", math.random(0, 0x7fffffff)))
  until vim.env[name] == nil and injected[name] == nil
  vim.fn.setenv(name, secret)
  injected[name] = secret
  return name
end

--- 把不同来源的密钥描述统一成 avante 的 `api_key_name`。
---
--- 支持的密钥来源：
---
--- - `string`：`$VAR` 读环境变量，其余按原文密钥注入随机环境变量
--- - `{type="ENV", value=...}`：读环境变量
--- - `{type="CMD", value=...}`：执行命令取 stdout
--- - `{type="TEXT", value=...}`：原文密钥，注入随机环境变量后返回变量名
---
--- @param key_desc string|table 密钥描述
--- @return string|nil api_key_name；环境变量未设置时返回空串
M.get_avante_key = function(key_desc)
  if type(key_desc) == "string" then
    if key_desc:sub(1, 1) == "$" then
      return vim.env[key_desc:sub(2)] or ""
    end
    return M.export_secret(key_desc)
  end
  if key_desc.type == "TEXT" then
    return M.export_secret(key_desc.value)
  end
  return twc(key_desc.type == "ENV", key_desc.value, "cmd:" .. key_desc.value)
end

return M
