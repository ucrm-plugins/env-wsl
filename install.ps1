


Write-Host -NoNewline "Removing any existing Docker containers for UISP..."
# Clear our any existing Docker containers for UISP
docker rm -f $(docker ps --filter name=unms* -aq) 2>$null
docker rm -f $(docker ps --filter name=ucrm* -aq) 2>$null
Write-Host "DONE!"

#wsl -u root bash -c "curl -fsSL https://uisp.ui.com/v1/install > /tmp/uisp_inst.sh"
wsl -u root -e ./uisp_inst.sh

