--- 读取 Pi 的模型配置，转换为本框架的 provider/module 描述。
---
--- 数据源：`~/.pi/agent/models.json`。测试或特殊安装可设置
--- `options.llm_modules.pi_config` 覆盖路径。只读取，不写 Pi 文件、不发网络请求。
---
--- 字段映射：
---
--- - `baseUrl` -> `endpoint`
--- - `models[].id` -> `provider.modules`
--- - `models[].maxTokens` -> 逐模型 `extra_request_body.max_completion_tokens`
--- - `apiKey` -> 密钥来源：`$VAR` 为环境变量，其余为 `TEXT` 原文密钥
--- - `defaultModel` -> `provider.model`（缺省时由 `init.lua` 取第一个模型）
---
--- Pi 专属的 `thinkingLevelMap`、`reasoning` 等字段不下发，avante 不认识它们。
---@module "global.llm_modules.pi"
local M = {}

local function config_path()
  local override = type(options) == 'table' and options.llm_modules and options.llm_modules.pi_config
  if type(override) == 'string' and override ~= '' then return vim.fn.expand(override) end
  return vim.fn.expand('~/.pi/agent/models.json')
end

--- 把 Pi 的 apiKey 转成密钥来源描述。
--- `$VAR` 表示环境变量；其余按原文密钥处理，由 utils 注入随机环境变量。
--- @param value string|nil Pi 配置中的 apiKey
--- @return table|nil 密钥来源描述
local function key_source(value)
  if type(value) ~= 'string' or value == '' then return nil end
  if value:sub(1, 1) == '$' then return { type = 'ENV', value = value:sub(2) } end
  return { type = 'TEXT', value = value }
end

--- 读取并缓存解析结果；缓存同时供 providers()/modules() 使用一次 JSON 解码。
--- @return table<string,table> provider 名到原始描述（含私有 `_pi_models`）
local cache
function M.load()
  if cache then return cache end
  local providers = {}
  local path = config_path()
  local file = io.open(path, 'rb')
  if file then
    local body = file:read('*a')
    file:close()
    local ok, decoded = pcall(vim.json.decode, body)
    local source = ok and type(decoded) == 'table' and decoded.providers or nil
    for name, pi in pairs(source or {}) do
      local modules = {}
      if type(pi) == 'table' and type(pi.models) == 'table' then
        for _, model in ipairs(pi.models) do
          if type(model) == 'table' and type(model.id) == 'string' then
            modules[#modules + 1] = model.id
          end
        end
      end
      if #modules > 0 then
        providers[name] = {
          -- 与 avante 的 openai 兼容 provider 对齐；接口协议差异交给 avante 处理。
          api_type = 'openai-completions',
          endpoint = pi.baseUrl,
          api_key_get_type = key_source(pi.apiKey),
          timeout = 30000,
          model = type(pi.defaultModel) == 'string' and pi.defaultModel or nil,
          modules = modules,
          -- 逐模型的 maxTokens：provider 级不设默认，避免把某个模型的上限
          -- 套到同 provider 的其它模型上。
          _pi_models = pi.models,
        }
      end
    end
  end
  cache = providers
  return cache
end

--- 返回可直接并入 provider 配置的 Pi 提供商。
--- 只保留本框架需要的字段，Pi 私有结构不下发。
--- @return table<string,table> provider 名到 `api_type/endpoint/api_key_get_type/timeout/model/modules`
function M.providers()
  local result = {}
  for name, desc in pairs(M.load()) do
    -- 只暴露本框架需要的字段，避免把 Pi 私有结构带进 provider 表。
    result[name] = {
      api_type = desc.api_type,
      endpoint = desc.endpoint,
      api_key_get_type = desc.api_key_get_type,
      timeout = desc.timeout,
      model = desc.model,
      modules = vim.deepcopy(desc.modules),
    }
  end
  return result
end

--- 返回 Pi 模型的请求参数覆盖项。
--- Pi 显式给出 `maxTokens` 时使用该值，否则上限取 12000；无其它字段的模型沿用 provider 默认参数。
--- @return table<string,table|true> 模型名到请求参数覆盖
function M.modules()
  local result = {}
  for _, desc in pairs(M.load()) do
    for _, model in ipairs(desc._pi_models or {}) do
      local body = { max_completion_tokens = type(model.maxTokens) == 'number' and model.maxTokens or 12000 }
      result[model.id] = { extra_request_body = body }
    end
  end
  return result
end

return M
