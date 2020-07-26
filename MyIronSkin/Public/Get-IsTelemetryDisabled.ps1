function Get-IsTelemetryDisabled {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $service = Get-Service 'DiagTrack'
        if ($service.Status -eq 'Running') {
            Write-Verbose 'Telemetry is still running'
            return $false
        }
        if ($service.StartType -ne 'Disabled') {
            Write-Verbose 'Telemetry is still enabled'
            return $false
        }

        return $true
    }
    
    end {
        
    }
}