-- mini.test 用例：provider/module 到 avante provider 描述的展开规则。
local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality
local T = MiniTest.new_set()

-- 被测文件按固定模块名 require 配置；直接替换 package.loaded 提供测试表。
local function build(providers, modules, pi_providers, pi_modules)
  local saved = {}
  local stubs = {
    ["global.llm_modules.provider"] = providers,
    ["global.llm_modules.modules"] = modules,
    ["global.llm_modules.utils"] = {
      name_to_avnate = { ["openai-completions"] = "openai" },
      get_avnate_key = function(desc)
        return "key:" .. tostring(desc.value or desc)
      end,
    },
  }
  for name in pairs(stubs) do
    saved[name] = package.loaded[name]
    package.loaded[name] = stubs[name]
  end
  saved["global.llm_modules"] = package.loaded["global.llm_modules"]
  package.loaded["global.llm_modules"] = nil
  local ok, result = pcall(function()
    return require("global.llm_modules").get_avnate()
  end)
  for name, value in pairs(saved) do
    package.loaded[name] = value
  end
  assert(ok, result)
  return result
end

local function provider(body, models, model)
  return {
    opencode = {
      api_type = "openai-completions",
      endpoint = "https://e",
      timeout = 1,
      model = model,
      modules = models,
      extra_request_body = body,
      api_key_get_type = { type = "ENV", value = "K" },
    },
  }
end

T["provider 提供基础参数，module 只覆盖自己声明的字段"] = function()
  local result = build(provider({ temperature = 0.5, max_completion_tokens = 100 }, { "m1", "m2" }, "m1"), {
    m1 = true,
    m2 = { extra_request_body = { temperature = 1 } },
  })
  eq(result["opencode-m1"].extra_request_body, { temperature = 0.5, max_completion_tokens = 100 })
  eq(result["opencode-m2"].extra_request_body, { temperature = 1, max_completion_tokens = 100 })
  eq(result["opencode-m1"].model, "m1")
  eq(result["opencode-m1"].model_names, { "m1", "m2" })
end

T["未定义模型静默使用 provider 默认参数"] = function()
  local result = build(provider({ temperature = 0.3 }, { "ghost", "known" }), { known = true })
  eq(result["opencode-ghost"].extra_request_body, { temperature = 0.3 })
  eq(result["opencode-known"].extra_request_body, { temperature = 0.3 })
  eq(result["opencode-ghost"].model, "ghost")
end

T["provider 名指向默认模型且不覆盖同名模型键"] = function()
  local result = build(provider({ temperature = 0.2 }, { "first", "opencode" }, "first"))
  eq(result["opencode"], result["opencode-first"])
  local same = build(provider({ temperature = 0.2 }, { "opencode" }, "opencode"))
  eq(same["opencode"].model, "opencode")
end

T["模块表可覆盖连接字段，结果与被引用的配置表解耦"] = function()
  local body = { temperature = 0.4 }
  local result = build(provider(body, { "alias" }, "alias"), {
    alias = { model = "real-name", timeout = 9, extra_request_body = { max_completion_tokens = 7 } },
  })
  eq(result["opencode-alias"].model, "real-name")
  eq(result["opencode-alias"].timeout, 9)
  eq(result["opencode-alias"].extra_request_body, { temperature = 0.4, max_completion_tokens = 7 })
  result["opencode-alias"].extra_request_body.temperature = 99
  eq(body.temperature, 0.4)
end

return T
