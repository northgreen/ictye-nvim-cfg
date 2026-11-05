--- @class llm.Module
--- @field extra_request_body? table<string,any> 与 provider 的请求参数深合并
--- @field model? string 覆盖真实模型名（别名场景）
--- @field timeout? integer 覆盖 provider 超时等连接级字段

--- 模型名到配置；`true` 表示缺省
--- @type table<string,llm.Module|true>
local M = {
  ["big-pickle"] = { temperature = 1, max_completion_tokens = 12287 },
  ["kimi-k2.5-free"] = true,
  ["qwen3.5-plus"] = true,
  ["glm-4.7-free"] = true,

  ["glm-5"] = true,
  ["qwen3-max-2026-01-23"] = true,
  ["qwen3-coder-next"] = true,
  ["qwen3-coder-plus"] = true,
  ["glm-4.7"] = true,
  ["kimi-k2.5"] = true,
  ["MiniMax-M2.5"] = true,
}

M = vim.tbl_extend('keep', M, require('global.llm_modules.pi').modules())

return M
