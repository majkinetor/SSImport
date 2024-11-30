param(
    [string] $Environment = 'top',
    [int] $BulkCopyBatchSize = 250000,
    [int] $BulkCopyTimeout = 600
)

Get-ChildItem $PSScriptRoot\inc\*.ps1 | % {. $_ }
Expand-Config

Import-Module -Name SQLServer
log "Environment:" $Environment

$Env = $Config.$Environment
$src = $env.Source; $src = Get-MsSqlConString @src
$dst = $env.Destination; $dst = Get-MsSqlConString @dst
$SourceDb      = Get-SqlDatabase -ConnectionString $src -Name $env.Source.Database
$DestinationDb = Get-SqlDatabase -ConnectionString $dst -Name $env.Destination.Database

if ($env.CreateDb -and !$DestinationDb) {
    log "CREATING DATABASE" $env.Destination.Database
    $master = Get-MsSqlConString -ServerInstance $env.Destination.ServerInstance -Database master -Username $env.Destination.Username -Password $env.Destination.Password
    $res = Invoke-Sqlcmd -ConnectionString $master -Query "CREATE DATABASE $($env.Destination.Database)"
}

drop
create
truncate
import

log "done"
