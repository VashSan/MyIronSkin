Set-StrictMode -Version Latest

function Start-IronSkin {
    function Main {
        $scriptPath = Split-Path -Parent $PSCommandPath
        $modulePath = Join-Path -Path $scriptPath -ChildPath MyIronSkin\MyIronSkin.psm1
        Import-Module $modulePath -Force

        if (Get-UserHasAdministratorRole) {
            Disable-Telemetry
        }
        else {
            # TODO apply non admin settings
            # Enable-ShowFileExtensions
            # Enable-ShowHiddenItems
            # Disable-RerunAppsAfterRestart
            # Disable-AdsOnLockScreen

            Start-AsAdministrator

            if(Get-Status) {
                exit 0
            } else {
                exit 1
            }
        }
    }

    function Get-Status {
        $warnings = 0

        Write-Host 'Telemetry: ' -NoNewline
        if (Get-IsTelemetryDisabled) {
            Write-Host 'enabled' -ForegroundColor Green
        } else {
            $warnings++
            Write-Host 'disabled' -ForegroundColor Yellow
        }            

        if ($warnings -eq 0) {
            Write-Host 'All settings applied' -ForegroundColor Green
        } else {
            Write-Host 'Some settings could not be applied' -ForegroundColor Yellow
        }
        Pause "Press ENTER to stop or close the window"
        return $warnings -eq 0
    }

    function Start-AsAdministrator {
        $powershell = [System.Diagnostics.Process]::GetCurrentProcess()
        $psi = New-Object System.Diagnostics.ProcessStartInfo $powerShell.Path
        $psi.Arguments = '-ExecutionPolicy ByPass -file ' + $script:MyInvocation.MyCommand.Path
        $psi.Verb = 'runas'
        $newProcess = [System.Diagnostics.Process]::Start($psi)
        $newProcess.WaitForExit()
    }

    function Pause ($message) {
        Write-Host "$message" -ForegroundColor Cyan
        $null = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
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
        # download LGPO.exe https://www.microsoft.com/en-us/download/details.aspx?id=55319
        # GPO %Systemroot%\System32\GroupPolicy
        # https://docs.microsoft.com/de-de/archive/blogs/secguide/lgpo-exe-local-group-policy-object-utility-v1-0
        #  Computer Configuration\Administrative Templates\Windows Components\Cloud Content\Do not show Windows Tips
    }

    Main

}

Start-IronSkin