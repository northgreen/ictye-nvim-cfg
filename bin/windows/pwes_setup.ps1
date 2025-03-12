$DownloadUrl = 'https://github.com/PowerShell/PowerShellEditorServices/releases/latest/download/PowerShellEditorServices.zip';
$ZipPath = "$HOME/Desktop/PowerShellEditorServices.zip";
$InstallPath = "$HOME/Desktop/PowerShellEditorServices";
Invoke-WebRequest -Method 'GET' -Uri $DownloadUrl -OutFile $ZipPath;
Expand-Archive -Path $ZipPath -DestinationPath $InstallPath;
