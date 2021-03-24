
[CmdletBinding]
function Get-IsUnwantedAppProtectionEnabled {
    (Get-MpPreference).PUAProtection -eq 1
}
