$scriptDir = $PSScriptRoot
$parentDir = Split-Path $scriptDir -Parent
$parentDir = Split-Path $parentDir -Parent
$luaPath = Join-Path $parentDir "lua" "fennel.lua"
& nvim -l $luaPath @args
