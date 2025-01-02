# v1.01 by majkinetor
# https://github.com/majkinetor/SSImport

param(
    [string[]] $Environments,
    [int] $BulkCopyBatchSize = 250000,
    [int] $BulkCopyTimeout = 600
)

Import-Module -Name SQLServer

Get-ChildItem $PSScriptRoot\inc\*.ps1 | % {$_; . $_ }
Expand-Config

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
        $params = @{
            Name           = $Env.Destination.Database
            ServerInstance = $Env.Destination.ServerInstance
            Username       = $Env.Destination.Username
            Password       = $Env.Destination.Password
            DataDir        = $Env.DataDir
        }
        $res = New-Database @params
    } else { drop }

    create
    truncate
    import
    log "done $e"
    log ("="*90)
}
log "done"
