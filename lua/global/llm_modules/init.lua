local providers = require("global.llm_modules.provider")
local modules = require("global.llm_modules.modules")
local utils = require("global.llm_modules.utils")

---@module "global.llm_modules"
local M = {}

--- 合并 provider 与 module 的请求参数。
--- module 为 `true` 或未定义时沿用 provider 的 `extra_request_body`；
--- 否则以 provider 配置为基础，用 module 的字段覆盖。
--- @param provider_body table|nil provider 级请求参数
--- @param module_desc table|true|nil module 配置
--- @return table 合并后的请求参数（与入参解耦）
local function extra_request_body(provider_body, module_desc)
  if type(module_desc) ~= "table" then
    return vim.deepcopy(provider_body or {})
  end
  return vim.tbl_deep_extend("force", {}, provider_body or {}, module_desc.extra_request_body or {})
end

--- 取 provider 的默认模型；未显式配置时用模型列表的第一个。
--- @param provider_desc table provider 描述
--- @return string|nil model
local function default_model(provider_desc)
  return provider_desc.model or provider_desc.modules[1]
end

--- 生成 avante 的 providers 表。
---
--- 每个模型同时提供 `"provider-model"` 键；另外提供指向默认模型的 `"provider"`
--- 别名键，若该名称已被同名模型描述占用则保留模型描述。
---
--- @return table<string,table> avante 的 providers 配置
function M.get_avnate()
  local ret = {}

  for provider_name, provider_desc in pairs(providers) do
    local model_names = vim.deepcopy(provider_desc.modules)

    for _, model_name in ipairs(model_names) do
      local key = provider_name .. "-" .. model_name
      local module_desc = modules[model_name]
      local desc = {
        __inherited_from = utils.name_to_avnate[provider_desc.api_type],
        endpoint = provider_desc.endpoint,
        api_key_name = utils.get_avnate_key(provider_desc.api_key_get_type),
        timeout = provider_desc.timeout,
        model = model_name,
        model_names = model_names,
        extra_request_body = extra_request_body(provider_desc.extra_request_body, module_desc),
      }

      -- 表值 module 可覆盖连接级字段；未定义的键保留 provider 配置。
      if type(module_desc) == "table" then
        desc = vim.tbl_extend("force", desc, module_desc)
        desc.extra_request_body = extra_request_body(provider_desc.extra_request_body, module_desc)
      end

      ret[key] = desc
    end

    local default_key = provider_name .. "-" .. default_model(provider_desc)
    ret[provider_name] = ret[provider_name] or ret[default_key]
  end

  return ret
end

return M
