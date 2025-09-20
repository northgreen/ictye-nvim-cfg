--- @return LazyPluginSpec
return {
    'luozhiya/fittencode.nvim',
    event = 'BufReadPre',
    opts = {
        completion_mode = 'source',
        source_completion = {
            enabled = true,
            engine = "bink"
        }
    }
}
