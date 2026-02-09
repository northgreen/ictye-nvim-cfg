local twc = require 'util.functions'.three_way_compare
local close_ai_key = twc(options.env.os.win == 1, "CLOSEAI_API_KEY", "cmd:pass show ai-key/close-ai")
local github_pat = "cmd:gh auth token"
local siliconflow_api_key = twc(options.env.os.win == 1, "SILICONFLOW_API_KEY", "cmd:pass show ai-key/siliconflow")
local opencode_api_key = twc(options.env.os.win == 1, "OPENCODE_API_KEY", "cmd:pass show ai-key/opencode")

local opencode = {
    __inherited_from = "openai",
    endpoint = "https://opencode.ai/zen/v1/",
    api_key_name = opencode_api_key,
    timeout = 30000,
    extra_request_body = {
        temperature = 1,
        max_completion_tokens = 12287,
    }
}
local closeai = {
    __inherited_from = "openai",
    endpoint = "https://api.openai-proxy.org/v1",
    api_key_name = close_ai_key,
    timeout = 30000,
    extra_request_body = {
        temperature = 1,
        max_completion_tokens = 12287,
    }
}
local siliconflow = {
    __inherited_from = "openai",
    endpoint = "https://api.siliconflow.cn/v1",
    api_key_name = siliconflow_api_key,
    timeout = 30000,
    extra_request_body = {
        temperature = 1,
        max_completion_tokens = 12287,
    }
}

local github_model = {
    __inherited_from = "openai",
    endpoint = "https://models.github.ai/inference/v1",
    api_key_name = github_pat,
    timeout = 30000,
    context_window = 7900,
    extra_request_body = {
        temperature = 1,
        max_completion_tokens = 8000,
    }
}

local qianwen = {
    __inherited_from = "openai",
    endpoint = "https://api.suanli.cn/v1",
    api_key_name = "QIANWEN_API_KEY",
    timeout = 30000,
    extra_request_body = {
        temperature = 1,
        max_completion_tokens = 8000,
    }
}

local gaf = {
    __inherited_from = "openai",
    endpoint = "https://api.chatanywhere.tech",
    api_key_name = "GAF_API_KEY",
    timeout = 30000,
    extra_request_body = {
        temperature = 1,
        max_completion_tokens = 4096,
    }
}

local function module(provider, model)
    local ret = provider
    provider.model = model
    return ret
end

return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
        provider = "opencode",
        system_prompt = function()
            local hub = require("mcphub").get_hub_instance()
            return hub and hub:get_active_servers_prompt() or ""
        end,
        custom_tools = function()
            return {
                require("mcphub.extensions.avante").mcp_tool(),
            }
        end,
        web_search_engine = {
            provider = "searchapi"
        },
        providers = {
            ["opencode-big-pickle"]    = module(opencode, 'big-pickle'),
            ["opencode-kimi-k25-free"] = module(opencode, 'kimi-k2.5-free'),
            ["opencode-glm-47-free"]   = module(opencode, 'glm-4.7-free'),
            ["closeai-gpt5"]           = module(closeai, 'gpt-5'),      -- too expensive!!
            ["closeai-ds"]             = module(closeai, 'deepseek-chat'),
            ["closeai-4o-mini"]        = module(closeai, 'gpt-4o-mini'),
            ["siliconflow-q38b"]       = module(siliconflow, 'deepseek-ai/DeepSeek-R1-0528-Qwen3-8B'),
            ["github-models-gpt4o"]    = module(github_model, 'gpt-4o'),
            ["qianwen-3"]              = module(qianwen, 'free:Qwen3-30B-A3B'),
            ["gaf"]                    = module(gaf, 'gpt-5')
        },
        act_providers = {
            ["opencode"] = {
                command = "opencode",
                args = { "acp" }
            }
        },
        shortcuts = {
            {
                name = "jci",
                describe = "Commit with jujutsu",
                details = "commit with jujutsu",
                prompt = "Use jj diff to view differences and gengrate commit message, then use jj commit to commit changes."
            }
        }
    },
    build = twc(options.env.os.win == 1,
        "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false",
        "make"),
    dependencies = {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "echasnovski/mini.pick",
        "nvim-telescope/telescope.nvim",
        "hrsh7th/nvim-cmp",
        "ibhagwan/fzf-lua",
        "nvim-tree/nvim-web-devicons",
        "zbirenbaum/copilot.lua", {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
            default = {
                embed_image_as_base64 = false,
                prompt_for_file_name = false,
                drag_and_drop = { insert_mode = true },
                use_absolute_path = true
            }
        }
    }, {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" }
    }
    }
}
