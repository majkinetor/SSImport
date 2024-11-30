function Log {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [int][AllowNull()] $Ident = $__log_ident,
        [switch] $IdentSave,
        [switch] $IdentInc,
        [switch] $IdentDec,
        [parameter(ValueFromRemainingArguments = $true)]
        [Object[]] $IgnoredArguments,
        [switch] $NoNewLine,
        [switch] $Raw,
        [int] $PadRight
    )
    $Msg = "$IgnoredArguments"

    if ($IdentInc)  { $Ident += 1 }
    if ($IdentDec)  { $Ident -= 1 }
    if ($IdentSave) { $script:__log_ident = $Ident }
    if ($PadRight) { $Msg = $Msg.PadRight($PadRight, ' ')}

    $now = Get-Date
    $elapsed = $now - $StartDate

    $log = '{0:HH\:mm\:ss} [{1:hh\:mm\:ss}]    {2}{3}' -f $now, $elapsed, (' '*$Ident*2), $Msg
    if ($Raw) { $log = $Msg }

    Write-Host $Log -NoNewline:$NoNewLine
}

$ErrorActionPreference = 'STOP'

$ScriptDir = Split-Path $PSScriptRoot
$ScriptName = Split-Path $ScriptDir -Leaf
$StartDate = Get-Date
$Config    = & $ScriptDir\config.ps1

New-Item -ItemType Directory $ScriptDir\logs\archive -ea 0 | Out-Null

$log_files = Get-ChildItem $ScriptDir\logs | Sort-Object CreationTime -Descending | Select-Object -Skip 1
if ($log_files.Count -gt 100) { $log_files | Select-Object -Skip 50 | % { Move-Item $_.FullName $ScriptDir\logs\archive -ea 0 } }

$LogPath = "$ScriptDir\logs\$(Get-Date -Format 'yyyy-MM-dd HH.mm.ss.fffffff').log"
$VerboseLogPath = "$ScriptDir\logs\$(Get-Date -Format 'yyyy-MM-dd HH.mm.ss.fffffff') verbose.log"

Start-Transcript $LogPath
