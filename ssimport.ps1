param(
    [string[]] $Environments = 'aw',
    [int] $BulkCopyBatchSize = 250000,
    [int] $BulkCopyTimeout = 600
)

Get-ChildItem $PSScriptRoot\inc\*.ps1 | % {. $_ }
Expand-Config

Import-Module -Name SQLServer

foreach ($e in $Environments) {
    $Env = $Config.$e

    $src = $Env.Source; $src = Get-MsSqlConString @src
    $dst = $Env.Destination; $dst = Get-MsSqlConString @dst

    log "Environment:" $e
    log "Source:" $Env.Source.ServerInstance $env.Source.Database -Ident 1
    log "Destination:" $Env.Destination.ServerInstance $env.Destination.Database -Ident 1

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
    log "done $e"
    log ("="*40)
}
log "done"
