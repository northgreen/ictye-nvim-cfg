-- mini.test 用例：读取 Pi models.json 并转换成本框架 provider/module 描述。
local MiniTest = require("mini.test")
local eq = MiniTest.expect.equality
local T = MiniTest.new_set()

-- 每次重新加载模块，丢弃上次的 JSON 缓存；用 options 覆盖路径，不触碰用户真实文件。
local function load_into(path)
  options = options or {}
  options.llm_modules = { pi_config = path }
  package.loaded["global.llm_modules.pi"] = nil
  return require("global.llm_modules.pi")
end

local function write(path, body)
  local file = assert(io.open(path, "wb"))
  file:write(body)
  file:close()
end

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
local good = dir .. "/models.json"
write(
  good,
  vim.json.encode({
    providers = {
      ["pi-provider"] = {
        baseUrl = "https://api.example.test/v1",
        api = "openai-completions",
        apiKey = "sk-test",
        models = {
          { id = "small", maxTokens = 1024, contextWindow = 8192 },
          { id = "bare" },
        },
      },
      broken = { models = "not-a-list" },
    },
  })
)
local env_path = dir .. "/env.json"
write(
  env_path,
  vim.json.encode({
    providers = { env = { baseUrl = "https://env", apiKey = "$MY_TEST_KEY", models = { { id = "m" } } } },
  })
)
local bad = dir .. "/bad.json"
write(bad, "{ not json")

T["解析 provider、模型列表与逐模型 maxTokens"] = function()
  local providers = load_into(good).providers()
  local p = providers["pi-provider"]
  eq(p.endpoint, "https://api.example.test/v1")
  eq(p.api_key_get_type, { type = "TEXT", value = "sk-test" })
  eq(p.api_type, "openai-completions")
  eq(p.modules, { "small", "bare" })
  eq(providers.broken, nil)

  local modules = load_into(good).modules()
  eq(modules.small.extra_request_body, { max_completion_tokens = 1024 })
  -- 没有 maxTokens 的模型也给出可用的默认上限，而不是照搬其它模型的值。
  eq(modules.bare.extra_request_body.max_completion_tokens, 12000)
end

T["$VAR 形式的密钥按环境变量读取"] = function()
  local provider = load_into(env_path).providers().env
  eq(provider.api_key_get_type, { type = "ENV", value = "MY_TEST_KEY" })

  -- utils 模块在完整配置中会加载 util.functions，这里用独立子进程验证真实实现。
  local child = MiniTest.new_child_neovim()
  child.restart({ "-u", "tests/minimal_init.lua" })
  local ok, err = pcall(function()
    child.lua([[
            _G.__key_check = (function()
                vim.env.MY_TEST_KEY = 'from-env'
                local utils = require('global.llm_modules.utils')
                local text = utils.get_avnate_key({ type = 'TEXT', value = 'sk-secret' })
                return { utils.get_avnate_key('$MY_TEST_KEY'), utils.get_avnate_key('literal'),
                    utils.get_avnate_key({ type = 'CMD', value = 'pass show x' }),
                    text, vim.env[text], text == utils.get_avnate_key({ type = 'TEXT', value = 'sk-secret' }) }
            end)()
        ]])
    local got = child.lua_get("_G.__key_check")
    eq(got[1], "from-env")
    eq(got[3], "cmd:pass show x")
    eq(got[5], "sk-secret")
    -- 原文密钥走随机环境变量名，且同名密钥只注入一次
    eq(type(got[4]), "string")
    eq(got[4]:match("^AVANTE_SECRET_%x+$") ~= nil, true)
    eq(got[6], true)
  end)
  child.stop()
  assert(ok, err)
end

T["配置缺失或损坏时静默返回空表"] = function()
  local pi = load_into(bad)
  eq(pi.providers(), {})
  eq(pi.modules(), {})
  local missing = dir .. "/missing.json"
  eq(load_into(missing).providers(), {})
end

T["默认模型取自 Pi defaultModel，缺省时回退首模型"] = function()
  local path = dir .. "/default.json"
  write(
    path,
    vim.json.encode({
      providers = {
        p = {
          baseUrl = "https://p",
          apiKey = "k",
          defaultModel = "second",
          models = { { id = "first" }, { id = "second" } },
        },
      },
    })
  )
  eq(load_into(path).providers().p.model, "second")
  local path2 = dir .. "/default2.json"
  write(
    path2,
    vim.json.encode({
      providers = {
        p = { baseUrl = "https://p", apiKey = "k", models = { { id = "first" }, { id = "second" } } },
      },
    })
  )
  eq(load_into(path2).providers().p.model, nil)
end

T["真实 Pi 配置可用，且不泄露到 avante 配置的私有字段"] = function()
  options = { env = { os = { win = 0 } }, llm_modules = { pi_config = vim.fn.expand("~/.pi/agent/models.json") } }
  package.loaded["global.llm_modules.pi"] = nil
  local all = require("global.llm_modules").get_avnate()
  local count, leaked = 0, false
  for _, desc in pairs(all) do
    count = count + 1
    if desc._pi_models ~= nil then
      leaked = true
    end
    eq(type(desc.endpoint), "string")
    eq(type(desc.model), "string")
    eq(type(desc.extra_request_body), "table")
  end
  assert(count > 0)
  eq(leaked, false)
end

T["provider/init.lua 与 modules/init.lua 末尾追加 Pi，本地条目优先"] = function()
  local child = MiniTest.new_child_neovim()
  child.restart({ "-u", "tests/minimal_init.lua" })
  local pi_file = dir .. "/merge.json"
  write(
    pi_file,
    vim.json.encode({
      providers = {
        -- 与本地 opencode 同名：必须保留本地 endpoint。
        opencode = {
          baseUrl = "https://pi-should-not-win",
          apiKey = "pi-key",
          models = { { id = "big-pickle", maxTokens = 1 } },
        },
        pi_only = {
          baseUrl = "https://pi-only",
          apiKey = "sk-pi",
          models = {
            { id = "model-a", maxTokens = 777 },
            { id = "big-pickle", maxTokens = 1 },
          },
        },
      },
    })
  )
  local ok, err = pcall(function()
    local code = [[
            (function(path)
                options = { env = { os = { win = 0 } }, llm_modules = { pi_config = path } }
                local provider = require('global.llm_modules.provider')
                local modules = require('global.llm_modules.modules')
                return { provider.opencode.endpoint, provider.pi_only.endpoint,
                    type(modules['big-pickle']) == 'table' and modules['big-pickle'].extra_request_body
                        and modules['big-pickle'].extra_request_body.max_completion_tokens or 'local',
                    modules['model-a'].extra_request_body.max_completion_tokens }
            end)(...)
        ]]
    eq(child.lua_get(code, { pi_file }), { "https://opencode.ai/zen/v1/", "https://pi-only", "local", 777 })
  end)
  child.stop()
  assert(ok, err)
end

return T
