## Example Module
## This module is an example of how to create a module with a function that can be self updated
## This example module contains a function that will find failed office 365 migrations
## Any .ps1 files in the module folder will be loaded into the module
## Please follow best practices when creating modules
## Your code should be wrapped in functions in these .ps1 files, which will be loaded into the module


## Requires Area
## Add any requirement statements here
#Requires -Module ExchangeOnlineManagement



function Get-FailedMigrations {
    <#
    .SYNOPSIS
        A cmdlet to find failed office 365 migrations

    .DESCRIPTION
        This cmdlet connects to Exchange Online, gets the migration users,
        and outputs the failed migration batch status

    .EXAMPLE
        Get-FailedMigrations
    #>
    [CmdletBinding()]Param()
    Begin{
        try{Connect-ExchangeOnline}
        catch{throw "Failed to connect to exchange online"}
    }

    Process{
        $failures = Get-MigrationUser -StatusSummary Failed -ErrorAction SilentlyContinue | Get-MigrationUserStatistics -ErrorAction SilentlyContinue

        if(!($failures)){
            return "No Failures"
        }

        $objs = @()

        $TypeData = @{
            TypeName = 'Cust.Migration.Error'
            DefaultDisplayPropertySet = 'Identity','Batch','FailureType'
        }
        Update-TypeData @TypeData

        $objs += $failures | %{
            [PSCustomObject]@{
                PSTypeName = 'Cust.Migration.Error'
                Identity = $_.Identity
                Batch = $_.BatchId
                FailureType = switch -wildcard ($_.Error.ToString().ToLower()) {
                    "*(401) unauthorized*" {"Expired Migration Endpoint";Break}
                    "*quota*" {"Mailbox Size Limit";Break}
                    "*smtp*proxy*" {"Missing Proxy Address";Break}
                    Default {"Unknown";Break}
                }
                Error = $_.Error
                FullDetails = $_ | Select-Object *
            }
        }
    }
    End{
        return $objs
    }
}