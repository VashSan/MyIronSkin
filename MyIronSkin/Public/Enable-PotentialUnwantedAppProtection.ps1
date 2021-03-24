[CmdletBinding]
function Enable-PotentialUnwantedAppProtection {
    function Main {
        if (Get-UserHasAdministratorRole) {
            try {
                Enable-Protection
            }
            catch {
                Write-Warning 'It was not possible to enable protection against potentially unwanted applications'
            }
        }
        else {
            throw 'This function requires elevated privileges'
        }
    }
    
    function Enable-Protection {
        Set-MpPreference -PUAProtection 1
    }
    
    Main
}
