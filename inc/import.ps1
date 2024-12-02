function import() {
    if (!$Env.Import) { return }

    log "Importing data"; $i = 1

    $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
    $SQLConnection.ConnectionString = $src
    $SQLConnection.Open()

    foreach ($table in $Env.Tables) {
        if ($table.SchemaImported -ne $table.Schema -or $table.NameImported -ne $table.Name) { $s = ' -> ' + $table.SchemaImported + '.' + $table.NameImported }
        log "$i/$($Env.Tables.Count)  $($table.Schema).$($table.Name)$s" -Ident 1 -NoNewLine -PadRight 80
        $i++

        $res = Invoke-Sqlcmd -ConnectionString $src -Query "select count(*) as count from ($($table.Query)) as t"
        log $res.count.ToString().PadRight(10, ' ') -Raw -NoNewLine
        if (!$res.count) { log -Raw; continue }

        $sqlCommand = New-Object system.Data.SqlClient.SqlCommand($table.Query, $SQLConnection)
        [System.Data.SqlClient.SqlDataReader] $sqlReader = $sqlCommand.ExecuteReader()

        $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($dst, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
        $bulkCopy.DestinationTableName = "$($table.SchemaImported).$($table.NameImported)"
        if ($table.Map) { foreach ($m in $table.Map.Keys) { $res = $bulkCopy.ColumnMappings.Add($m, $table.Map.$m) } }

        $bulkCopy.BulkCopyTimeOut = $BulkCopyTimeout
        $bulkCopy.BatchSize = $BulkCopyBatchSize
        $bulkCopy.WriteToServer($sqlReader)
        $sqlReader.Close()
        $bulkCopy.Close()
        log "ok" -Raw
    }
}