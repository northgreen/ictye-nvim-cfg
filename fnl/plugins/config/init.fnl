{
  :setup (fn [] 
    (let [
      nvlime (require "plugins.config.nvlime")
      conjure (require "plugins.config.conjure")
      ]
      (set vim.g.nvlime_config nvlime)
      (conjure.setup)))
}
