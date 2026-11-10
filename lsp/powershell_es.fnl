;;; @brief
;;;
;;; https://github.com/PowerShell/PowerShellEditorServices
;;;
;;; Language server for PowerShell.
;;;
;;; To install, download and extract PowerShellEditorServices.zip
;;; from the [releases](https://github.com/PowerShell/PowerShellEditorServices/releases).
;;; To configure the language server, set the property `bundle_path` to the root
;;; of the extracted PowerShellEditorServices.zip.
;;;
;;; ```lua
;;; vim.lsp.config('powershell_es', {
;;;   bundle_path = 'c:/w/PowerShellEditorServices',
;;; })
;;; ```
;;;
;;; By default the language server is started in `pwsh` (PowerShell Core). This can be changed by specifying `shell`.
;;;
;;; ```lua
;;; vim.lsp.config('powershell_es', {
;;;   bundle_path = 'c:/w/PowerShellEditorServices',
;;;   shell = 'powershell.exe',
;;; })
;;; ```
;;;
;;; Note that the execution policy needs to be set to `Unrestricted` for the languageserver run under PowerShell
;;;
;;; If necessary, specific `cmd` can be defined instead of `bundle_path`.
;;; See [PowerShellEditorServices](https://github.com/PowerShell/PowerShellEditorServices#standard-input-and-output)
;;; to learn more.
;;;
;;; ```lua
;;; vim.lsp.config('powershell_es', {
;;;   cmd = {'pwsh', '-NoLogo', '-NoProfile', '-Command', "c:/PSES/Start-EditorServices.ps1 ..."},
;;; })
;;; ```

;;;@type vim.lsp.Config
{:cmd (λ [?dispatchers]
    (let [temp_path (vim.fn.stdpath "cache")
        bundle_path vim.lsp.config.powershell_es.bundle_path]
      (let [bundle_path "/opt/powershell-editor-services"
          shell (or vim.lsp.config.powershell_es.shell "pwsh")
          command_fmt "& '%s/PowerShellEditorServices/Start-EditorServices.ps1' -BundledModulesPath '%s' -LogPath '%s/powershell_es.log' -SessionDetailsPath '%s/powershell_es.session.json' -FeatureFlags @() -AdditionalModules @() -HostName nvim -HostProfileId 0 -HostVersion 1.0.0 -Stdio -LogLevel Normal"
          command (command_fmt:format bundle_path bundle_path temp_path temp_path)
          cmd [shell "-NoLogo" "-NoProfile" "-Command" command]]
        (vim.lsp.rpc.start cmd ?dispatchers))))
  :filetypes ["ps1"]
  :root_markers ["PSScriptAnalyzerSettings.psd1" ".git"]
  :capabilities ((require "global.language.capabilities"))}
