param(
    [string] $Environment = 'jafintest',
    [int] $BulkCopyBatchSize = 250000,
    [int] $BulkCopyTimeout = 600
)


Get-ChildItem $PSScriptRoot\inc\*.ps1 | % { . $_ }
Expand-Config

Import-Module -Name SQLServer
log "Environment:" $Environment

# $options = New-Object -TypeName Microsoft.SqlServer.Management.Smo.ScriptingOptions
# $options.DriAll = $true
# $options.SchemaQualify = $true

# $connection = New-Object -TypeName Microsoft.SqlServer.Management.Common.ServerConnection -ArgumentList $serverInstance
# $connection.LoginSecure = $false
# $connection.Login = $user
# $connection.Password = $password
# $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $connection

$env = $Config.$Environment
$src = $env.Source; $src = Get-MsSqlConString @src
$dst = $env.Destination; $dst = Get-MsSqlConString @dst

$db = Get-SqlDatabase -ConnectionString $src -Name $env.Source.Database

if ($env.CreateDb -and !(Get-SqlDatabase -ConnectionString $dst -Name $env.Destination.Database)) {
    log "CREATING DATABASE" $env.Destination.Database
    $master = Get-MsSqlConString -ServerInstance $env.Destination.ServerInstance -Database master -Username $env.Destination.Username -Password $env.Destination.Password
    $res = Invoke-Sqlcmd -ConnectionString $master -Query "CREATE DATABASE $($env.Destination.Database)"
}

$tables = foreach ($table in $env.Tables) {
    $table -is [string] ? @{ Name = $table } : $table
}

if ($Env.Create) {
    log "Creating tables"; $i = 1
    foreach ($table in $tables) {
        log "$i/$($tables.Count)  $($table.Name)" -Ident 1 -NoNewLine -PadRight 60
        $i++

        $a = $table.Name -split '\.'
        if ($a[1]) { $schema = $a[0]; $tbl = $a[1]} else { $schema = 'dbo'; $tbl = $a[0] }
        $tbl = $db.Tables | ? { $_.Schema -eq $schema -and $_.Name -eq $tbl }
        if (!$tbl) { throw "cant find table $($table.Name)"}

        [string] $tableScript = $tbl.Script() | Select-Object -Skip 2
        try {
            Invoke-Sqlcmd -ConnectionString $dst -Query "CREATE SCHEMA $schema" -ErrorAction Ignore
            $res = Invoke-Sqlcmd -ConnectionString $dst -Query $tableScript
            log "ok" -Raw
        } catch {
            if ($_.Exception.InnerException.Number -ne 2714) { throw $_ }   # There is already an object named '<$table>' in the database.
            log  "ok (exists)" -Raw
        }
    }
}

if ($Env.Truncate) {
    log "Truncating tables"; $i = 1
    foreach ($table in $tables) {
        log "$i/$($tables.Count)  $($table.Name)" -Ident 1
        $i++

        $res = Invoke-Sqlcmd -ConnectionString $dst -Query "truncate table $($table.Name)"
    }
}

if ($Env.Data) {
    log "Inserting data"; $i = 1

    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $SQLConnection.ConnectionString = $src
    $SQLConnection.Open()

    foreach ($table in $tables) {
        log "$i/$($tables.Count)  $($table.Name)" -Ident 1 -NoNewLine -PadRight 50
        $i++

        $res = Invoke-Sqlcmd -ConnectionString $src -Query "select count(*) as count from $($table.Name)"
        log $res.count.ToString().PadRight(10, ' ') -Raw -NoNewLine
        if (!$res.count) { log -Raw; continue}


        $sql = $table.Query
        if (!$sql) { $sql = "select * from $($table.Name)"} else { $sql = $sql.Replace('[]', $table.Name) }

        $sqlCommand = New-Object system.Data.SqlClient.SqlCommand($sql, $SQLConnection)
        [System.Data.SqlClient.SqlDataReader] $sqlReader = $sqlCommand.ExecuteReader()

        $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($dst, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
        $bulkCopy.DestinationTableName = $table.Name
        $bulkCopy.BulkCopyTimeOut = $BulkCopyTimeout
        $bulkCopy.BatchSize = $BulkCopyBatchSize
        $bulkCopy.WriteToServer($sqlReader)
        $sqlReader.Close()
        $bulkCopy.Close()
        log "ok" -Raw
    }
}

log "done"
