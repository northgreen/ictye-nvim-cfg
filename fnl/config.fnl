(let [ plugin (require :plugins.init)
       autocommands (require :autocommands)]
  (plugin.setup)
  (autocommands.setup)
 )
nil
