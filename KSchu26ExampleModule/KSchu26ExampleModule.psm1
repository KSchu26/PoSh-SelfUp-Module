## This is the main module file for KSchu26ExampleModule
## This file will load all .ps1 files in the module folder
## Currently, this will load all functions in all .ps1 files, public or private
## I plan to add a way to specify which functions to load in the future



param (
    [ValidateSet(
        'useScriptBlock',
        'useScript'
    )]
    [String]$DotSourceMethod = 'useScriptBlock'
)

# Attempt to gather the name of the module from the script path
$ModuleName = $PSScriptRoot.Split("\")[-1]

# Confirm the module name was found
if(-not $ModuleName){
    Write-Warning "Failed to find self-updating module name"
    return
}




# Scriptblock that reloads the module
$ReloadScriptBlock = {
    Write-Host "Attempting to reload module"
    try{
        $LatestVersion = (Find-Module -Name $ModuleName).Version
        $LoadedVersion = Get-Module -Name $ModuleName
        Write-Verbose "Loaded Version: $LoadedVersion"
        write-Verbose "Latest Version: $LatestVersion"
        Import-Module $ModuleName -Force -Global -RequiredVersion $LatestVersion -verbose
        Write-Host "Successfully loaded version $LatestVersion"
    }
    catch{
        Write-Warning "Failed to reload module"
    }
}

# Scriptblock that updates the module
$UpdateScriptBlock = {
    try{
        Write-Host "Attempting to update module"
        Update-Module -Name $ModuleName
    }
    catch{
        Write-Warning "Failed to update module"
        Write-Warning "Will retry with verbose"
        try {
            Update-Module -Name $ModuleName -verbose
        }
        catch {
            Write-Warning "Failed to update module with verbose"
        }
        Read-Host -Prompt "Press Enter to continue"
    }
}

# Check if the module is installed
Write-Verbose "Checking if module is installed"
$ModuleInstalled = get-module -listavailable $ModuleName | Select-Object Name,Version -ErrorAction SilentlyContinue | Sort-Object -Property Version -Descending | Select-Object -First 1
Write-Verbose "Module installed: $($null -ne $ModuleInstalled)"
Write-Verbose "Module version: $($ModuleInstalled.Version)"

# If the module is installed, check if it is the latest version
$InstalledVersion = $ModuleInstalled.Version
$LatestVersion = (Find-Module -Name $ModuleName).Version

Write-Verbose "Installed version: $InstalledVersion"
Write-Verbose "Latest version: $LatestVersion"

# Alert the user if the module is not up to date
If($InstalledVersion -ne $LatestVersion){
    Write-Warning "Module is not up to date"
    Write-Host "Installed version: $InstalledVersion"
    Write-Host "Latest version: $LatestVersion"
    # Update the module
    Start-Process -FilePath powershell.exe -ArgumentList $UpdateScriptBlock -verb RunAs -Wait
    
    # Check if the update was successful
    $ModuleInstalledCheck = get-module -listavailable $ModuleName | Select-Object Name,Version -ErrorAction SilentlyContinue | Sort-Object -Property Version -Descending | Select-Object -First 1
    
    if($ModuleInstalledCheck.Version -eq $LatestVersion){
        Write-Host "Update was successful"
        Write-Host "Reloading module"
        Invoke-Command -ScriptBlock $ReloadScriptBlock
        return
    }
    else{
        Write-Warning "Update was not successful"
        Write-Warning "Installed version: $($ModuleInstalledCheck.Version)"
        Write-Warning "Latest version: $LatestVersion"
        Read-Host -Prompt "Press Enter to continue"
    }
}

foreach ($file in Get-ChildItem -Path $PSScriptRoot\*.ps1) {
    if ($DotSourceMethod -eq 'useScriptBlock') {
        # Avoiding bug in WMF5/Install-Module
        # See: https://constantinekokkinos.com/articles/64/troubleshooting-powershell-and-net-when-error-messages-are-not-enough
        $ExecutionContext.InvokeCommand.InvokeScript(
            $false, 
            (
                [scriptblock]::Create(
                    [io.file]::ReadAllText(
                        $file.FullName,
                        [Text.Encoding]::UTF8
                    )
                )
            ), 
            $null, 
            $null
        )
    } else {
        . $file.FullName
    }
}
