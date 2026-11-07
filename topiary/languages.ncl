{
  languages = {
    fennel = {
      extensions = ["fnl"],
      grammar.source = {
        git = {
          git = "https://github.com/alexmozaidze/tree-sitter-fennel.git" ,
          rev = "8c0d338cdb95285eb5d59a70b513ddaae374786c",
        }
      },
      indent = "  ", # Fennel 社区惯例：两空格缩进
    }
  }
}
