
$distro = "Ubuntu-20.04"

wsl --set-default $distro 1>$null

Write-Host -NoNewline "Updating /etc/wsl.conf in $distro..."
$wsl = @"
[boot]
systemd=true

[network]
hostname=uisp.dev
generateHosts=false
"@

wsl -u root bash -c "printf '${wsl}\n' | tee /etc/wsl.conf" 1>$null
Write-Host "DONE!"

wsl --terminate $distro 1>$null
#net stop LxssManager
#net start LxssManager

