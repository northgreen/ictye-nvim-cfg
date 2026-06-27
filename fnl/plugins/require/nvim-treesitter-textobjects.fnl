{
  1 "nvim-treesitter/nvim-treesitter-textobjects"
  :branch "main"
  :opts {
    :textobjects  {
    :select  {
      :enable  true
      :lookahead  true
      :selection_modes {
        "@parameter.outer"  "v"
        "@function.outer"  "V"
        "@class.outer"  "<c-v>"
      }
      
      :include_surrounding_whitespace true
      }
    }
    :move {
      :set_jump true
    }
  }
}
