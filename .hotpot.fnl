;; .hotpot.fnl 
{
 ;; Required, string, valid: hotpot/2
 ;; Describes expected schema for table.
 :schema :hotpot/2

 ;; Required, string, valid: cache|colocate
 ;; Describes target location of lua files. `cache` places lua files "out of
 ;; tree" in a directory loadable by neovim, `colocate` places lua files "in
 ;; tree", next to their fennel counterparts.
 ;;
 ;; When no `.hotpot.fnl` file is present in your config directory,
 ;; the target defaults to :cache. You may set it to :colocate by adding a
 ;; .hotpot.fnl file.
 ;; Be aware that its the users responsibility to remove previously
 ;; generated lua files when swapping targets in either direction.
 ;;
 ;; For plugins, the only valid value is `colocate`.
 :target :cache

 ;; All other keys are optional.

 ;; Optional, boolean
 ;; If true (default), any single compilation error will prevent any changes
 ;; from being written.
 :atomic? true

 ;; Optional, boolean
 ;; If true (default: false), output messages after every successful
 ;; compilation instead of just on error.
 :verbose? true

 ;; Optional, function
 ;; If provided, all compiled fennel source is passed to the function, along
 ;; with its path, relative to `.hotpot.fnl`. The function must return the
 ;; modified source.
 ;; Transform is not called automatically when using the compile and eval API.
 :transform (fn [src path] src)

 ;; Optional, list of strings
 ;; Glob patterns to ignore when performing compile and clean operations,
 ;; relative to the .hotpot.fnl file.
 ;;
 ;; Files matching `.lua` patterns are never considered orphans and never removed.
 ;; Files matching `.fnl` patterns are never compiled.
 ;; Files matching `.fnlm` patterns are never considered when performing stale checks.
 :ignore [:some/lib/**/*.lua :junk/*.fnl]

 ;; Optional, table
 ;; Fennel compiler options, passed directly to `fennel.compile-string`.
 ;;
 ;; Hotpot enables strict global checking by default to prevent referencing
 ;; unknown or misspelled variables. To restore Fennel's default
 ;; behaviour, you can set `allowedGlobals` to `false`.
 ;;
 ;; If you wish to reference `vim` in your macros, set `:extra-compiler-env {: vim}`.
 ;;
 ;; Note that `error-pinpoint` is always forced to false and `filename` is
 ;; always set to the correct value.
 ;;
 ;; See Fennel's own API documentation and --help for further details.
 :compiler {:allowedGlobals (icollect [k _ (pairs _G)] k)
            :extra-compiler-env {: vim}
            :error-pinpoint false}
}
