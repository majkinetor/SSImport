function import() {
    if (!$Env.Import) { return }

    log "Importing data"; $i = 1

    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $SQLConnection.ConnectionString = $src
    $SQLConnection.Open()

    foreach ($table in $Env.Tables) {
        log "$i/$($Env.Tables.Count)  $($table.Name)" -Ident 1 -NoNewLine -PadRight 50
        $i++

        $res = Invoke-Sqlcmd -ConnectionString $src -Query "select count(*) as count from ($($table.Query)) as t"
        log $res.count.ToString().PadRight(10, ' ') -Raw -NoNewLine
        if (!$res.count) { log -Raw; continue }

        $sqlCommand = New-Object system.Data.SqlClient.SqlCommand($table.Query, $SQLConnection)
        [System.Data.SqlClient.SqlDataReader] $sqlReader = $sqlCommand.ExecuteReader()

        $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($dst, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
        $bulkCopy.DestinationTableName = "[$($table.Schema)].[$($table.Name)]"
        $bulkCopy.BulkCopyTimeOut = $BulkCopyTimeout
        $bulkCopy.BatchSize = $BulkCopyBatchSize
        $bulkCopy.WriteToServer($sqlReader)
        $sqlReader.Close()
        $bulkCopy.Close()
        log "ok" -Raw
    }
}