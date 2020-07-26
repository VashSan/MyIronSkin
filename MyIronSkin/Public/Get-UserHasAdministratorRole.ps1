function Get-UserHasAdministratorRole {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $princ = New-Object System.Security.Principal.WindowsPrincipal($identity)
    if (!$princ.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $false
    }
    else {
        return $true
    }
}