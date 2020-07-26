
Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Disables the windows telemetry collection and submission.
.DESCRIPTION
    This function stops the service "DiagTrack" which is responsible to collect 
    and submit telemetry data to Microsoft. You can do this on your own
.EXAMPLE Disable telemetry from shell
    PS :> Disable-TelemetryTracing
#>
function Disable-TelemetryTracing {
    function Main {
        if (HasAdministratorRole) {
            try {
                $service = Get-Service -Name 'DiagTrack' 
                $service | Stop-Service
                $service | Set-Service -StartupType Disabled
            }
            catch {
                Write-Warning 'It was not possible to disable Telemetry'
            }
        }
        else {
            "no admin rights, trying to open in admin rights"
            $proc = StartMySelfWithAdminRole
            $proc.WaitForExit()

            $service = Get-Service 'DiagTrack'
            $warnings = 0
            if ($service.Status -eq 'Running') {
                Write-Warning 'Telemetry: It was not possible to stop the service'
                $warnings++
            }
            if ($service.StartType -ne 'Disabled') {
                Write-Warning 'Telemetry: It was not possible to disable the auto start'
                $warnings++
            }

            if ($warnings -eq 0) {
                Write-Host 'Telemetry disabled' -ForegroundColor Green
            } 
            pause "Press ENTER to stop or close the window"
        }
    }

    function HasAdministratorRole() {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $princ = New-Object System.Security.Principal.WindowsPrincipal($identity)
        if (!$princ.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
            return $false
        }
        else {
            return $true
        }
    }
    
    function StartMySelfWithAdminRole {
        $powershell = [System.Diagnostics.Process]::GetCurrentProcess()
        $psi = New-Object System.Diagnostics.ProcessStartInfo $powerShell.Path
        $psi.Arguments = '-ExecutionPolicy ByPass -file ' + $script:MyInvocation.MyCommand.Path
        $psi.Verb = 'runas'
        $newProcess = [System.Diagnostics.Process]::Start($psi)
        return $newProcess
    }

    function pause ($message) {
        Write-Host "$message" -ForegroundColor Cyan
        $null = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }

    Main
}

function Enable-ShowFileExtensions {
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value "0"
}

function Enable-ShowHiddenItems {
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value "1"
}

function Disable-RerunAppsAfterRestart {
    Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name DisableAutomaticRestartSignOn -Value "1"
}

function Disable-TipsOnLockScreen {
  # GPO %Systemroot%\System32\GroupPolicy
  # https://docs.microsoft.com/de-de/archive/blogs/secguide/lgpo-exe-local-group-policy-object-utility-v1-0
  #  Computer Configuration\Administrative Templates\Windows Components\Cloud Content\Do not show Windows Tips
}

Disable-TelemetryTracing
# Enable-ShowFileExtensions
# Enable-ShowHiddenItems
# Disable-RerunAppsAfterRestart
# Disable-AdsOnLockScreen