local twc = require 'util.functions'.three_way_compare
local close_ai_key = twc(options.env.os.win==1,"CLOSEAI_API_KEY","cmd:pass show ai-key/close-ai")
local github_pat = "cmd:gh auth token"
local siliconflow_api_key = twc(options.env.os.win==1,"SILICONFLOW_API_KEY","cmd:pass show ai-key/siliconflow")

return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
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
        provider = "github_models_gpt4o",
        providers = {
            closeai_gpt5 = { -- too expensive!!
                __inherited_from = "openai",
                endpoint = "https://api.openai-proxy.org/v1",
                model = "gpt-5",
                api_key_name = close_ai_key,
                timeout = 30000,
                extra_request_body = {
                    temperature = 1,
                    max_completion_tokens = 12287,
                }
            },
            closeai_ds = {
                __inherited_from = "openai",
                endpoint = "https://api.openai-proxy.org/v1",
                model = "deepseek-chat",
                api_key_name = close_ai_key,
                timeout = 30000,
                extra_request_body = {
                    temperature = 1,
                    max_completion_tokens = 12287,
                }
            },
            closeai_4o_mini = {
                __inherited_from = "openai",
                endpoint = "https://api.openai-proxy.org/v1",
                model = "gpt-4o-mini",
                api_key_name = close_ai_key,
                timeout = 30000,
                extra_request_body = {
                    temperature = 1,
                    max_completion_tokens = 12287,
                }
            },
            siliconflow_q38b = {
                __inherited_from = "openai",
                endpoint = "https://api.siliconflow.cn/v1",
                model = "deepseek-ai/DeepSeek-R1-0528-Qwen3-8B",
                api_key_name = siliconflow_api_key,
                timeout = 30000,
                extra_request_body = {
                    temperature = 1,
                    max_completion_tokens = 12287,
                }
            },
            github_models_gpt4o = {
                __inherited_from = "openai",
                endpoint = "https://models.github.ai/inference/v1",
                model = "gpt-4o",
                api_key_name = github_pat,
                timeout = 30000,
                context_window = 7900,
                extra_request_body = {
                    temperature = 1,
                    max_completion_tokens = 8000,
                }
            },
            qianwen_3 = {
                __inherited_from = "openai",
                endpoint = "https://api.suanli.cn/v1",
                model = "free:Qwen3-30B-A3B",
                api_key_name = "QIANWEN_API_KEY",
                timeout = 30000,
                extra_request_body = {
                    temperature = 1,
                    max_completion_tokens = 8000,
                }
            },
            gaf = {
                __inherited_from = "openai",
                endpoint = "https://api.chatanywhere.tech",
                model = "gpt-5",
                api_key_name = "GAF_API_KEY",
                timeout = 30000,
                extra_request_body = {
                    temperature = 1,
                    max_completion_tokens = 4096,
                }
            }

        },
    },
    build = twc(options.env.os.win==1,
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
