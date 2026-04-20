return {
  'milanglacier/minuet-ai.nvim',
  opts = {
    provider = 'openai_compatible ',
    request_timeout = 2.5,
    throttle = 1500, -- Increase to reduce costs and avoid rate limits
    debounce = 600,  -- Increase to reduce costs and avoid rate limits
    blink = {
      enable_auto_complete = true,
    },
    provider_options = {
      openai_compatible = {
        api_key = 'DEEPSEEK_API_KEY',
        end_point = 'https://api.deepseek.com/beta/v1/chat/completions',
        model = 'deepseek/deepseek-v4-flash',
        name = 'Openrouter',
        optional = {
          max_tokens = 56,
          top_p = 0.9,
          provider = {
            -- Prioritize throughput for faster completion
            sort = 'throughput',
          },
          -- disable thinking to avoid first token latency
          reasoning_effort = 'none'
        },
      },
    },
  }
}
