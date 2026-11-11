-- provider 级配置：连接信息、密钥来源、默认模型和基础请求参数。
local twc = require("util.functions").three_way_compare

-- 密钥来源描述。
--- @class llm.KeySource
--- @field type "ENV" | "TEXT" | "CMD" `"ENV"` 读环境变量；`"TEXT"` 原文密钥（注入随机环境变量）；其他值按命令执行
--- @field value string 环境变量名或命令；CMD 类型会由 utils 加 `cmd:` 前缀

-- 单个 provider 的配置。
--- @class llm.Provider
--- @field api_type string API 类型
--- @field endpoint string 接口地址
--- @field api_key_get_type llm.KeySource|string 密钥来源描述
--- @field timeout integer 请求超时（毫秒）
--- @field model? string 默认模型
--- @field context_window? integer 上下文窗口
--- @field extra_request_body? table<string,any> 默认请求参数
--- @field modules string[] 此 provider 暴露的模型列表

local function env_or_pass(name, pass_key)
  return {
    type = twc(options.env.os.win == 1, "ENV", "CMD"),
    value = twc(options.env.os.win == 1, name, "pass show ai-key/" .. pass_key),
  }
end

--- provider 名到 provider 配置。
--- @type table<string,llm.Provider>
local M = {}

M.opencode = {
  api_type = "openai-completions",
  endpoint = "https://opencode.ai/zen/v1/",
  api_key_get_type = env_or_pass("OPENCODE_API_KEY", "opencode"),
  timeout = 30000,
  model = "big-pickle",
  extra_request_body = {
    temperature = 1,
    max_completion_tokens = 12287,
  },
  modules = {
    "big-pickle",
    "kimi-k2.5-free",
    "glm-4.7-free",
  },
}

M.closeai = {
  api_type = "openai-completions",
  endpoint = "https://api.openai-proxy.org/v1",
  api_key_get_type = env_or_pass("CLOSEAI_API_KEY", "close-ai"),
  timeout = 30000,
  model = "deepseek-chat",
  extra_request_body = {
    temperature = 1,
    max_completion_tokens = 12287,
  },
  modules = {
    "deepseek-chat",
    "gpt-5",
    "gpt-4o-mini",
  },
}

M.siliconflow = {
  api_type = "openai-completions",
  endpoint = "https://api.siliconflow.cn/v1",
  api_key_get_type = env_or_pass("SILICONFLOW_API_KEY", "siliconflow"),
  timeout = 30000,
  model = "deepseek-ai/DeepSeek-R1-0528-Qwen3-8B",
  extra_request_body = {
    temperature = 1,
    max_completion_tokens = 12287,
  },
  modules = {
    "deepseek-ai/DeepSeek-R1-0528-Qwen3-8B",
  },
}

M.github = {
  api_type = "openai-completions",
  endpoint = "https://models.github.ai/inference/v1",
  -- GitHub PAT 由 gh 命令行提供，不存本地密码库。
  api_key_get_type = { type = "CMD", value = "gh auth token" },
  timeout = 30000,
  context_window = 7900,
  model = "gpt-4o",
  extra_request_body = {
    temperature = 1,
    max_completion_tokens = 8000,
  },
  modules = {
    "gpt-4o",
  },
}

M.qianwen = {
  api_type = "openai-completions",
  endpoint = "https://api.suanli.cn/v1",
  api_key_get_type = { type = "ENV", value = "QIANWEN_API_KEY" },
  timeout = 30000,
  model = "free:Qwen3-30B-A3B",
  extra_request_body = {
    temperature = 1,
    max_completion_tokens = 8000,
  },
  modules = {
    "free:Qwen3-30B-A3B",
  },
}

M.gaf = {
  api_type = "openai-completions",
  endpoint = "https://api.chatanywhere.tech",
  api_key_get_type = { type = "ENV", value = "GAF_API_KEY" },
  timeout = 30000,
  model = "gpt-5",
  extra_request_body = {
    temperature = 1,
    max_completion_tokens = 4096,
  },
  modules = {
    "gpt-5",
  },
}

M.bailian = {
  api_type = "openai-completions",
  endpoint = "https://coding.dashscope.aliyuncs.com/v1",
  api_key_get_type = env_or_pass("BAILINAN_API_KEY", "qianwen-bailian"),
  timeout = 30000,
  -- 原配置默认 MiniMax-M2.5，此处保持一致的默认模型。
  model = "MiniMax-M2.5",
  extra_request_body = {
    temperature = 1,
    max_completion_tokens = 4096,
  },
  modules = {
    "qwen3.5-plus",
    "qwen3-max-2026-01-23",
    "qwen3-coder-next",
    "qwen3-coder-plus",
    "glm-5",
    "glm-4.7",
    "kimi-k2.5",
    "MiniMax-M2.5",
  },
}

M = vim.tbl_extend("keep", M, require("global.llm_modules.pi").providers())

return M
