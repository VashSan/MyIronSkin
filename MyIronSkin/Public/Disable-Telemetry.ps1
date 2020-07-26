[CmdletBinding]
function Disable-Telemetry {
    function Main {
        if (Get-UserHasAdministratorRole) {
            try {
                Disable-TelemetryService
            }
            catch {
                Write-Warning 'It was not possible to disable Telemetry'
            }
        }
        else {
            throw 'This function requires elevated privileges'
        }
    }
    
    function Disable-TelemetryService {
        $service = Get-Service -Name 'DiagTrack' 
        $service | Stop-Service
        $service | Set-Service -StartupType Disabled
    }
    
    Main
}
