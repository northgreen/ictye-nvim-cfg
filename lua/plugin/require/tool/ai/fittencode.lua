--- @return LazyPluginSpec
return {
    'luozhiya/fittencode.nvim',
    event = 'BufReadPre',
    opts = {
        -- completion_mode = 'inline', -- too noisy!!!
        completion_mode = 'source',
        source_completion = {
            enabled = true,
            engine = "blink"
        }
    }
}
