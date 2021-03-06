function Move-ToNextPowerShellTab {
    <#
    .Synopsis
        Moves to the next PowerShell Tab
    .Description
        Moves to the next PowerShell Tab
    .Example
        Move-ToNextPowerShellTab
    #>
    param()
    for ($index = 0; $index -lt $psise.PowerShellTabs.Count; $index++) {
        if ($psise.PowerShellTabs[$index] -eq $psise.CurrentPowerShellTab) {
            break       
        } 
    }
    
    $tab = $psise.PowerShellTabs[$index  +1]
    if (-not $tab) {
        $psise.PowerShellTabs.SetSelectedPowerShellTab($psise.PowerShellTabs[0])
    } else {
        $psise.PowerShellTabs.SetSelectedPowerShellTab($tab)
    }
}