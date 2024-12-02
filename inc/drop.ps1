function drop() {
    if (!$Env.Drop) { return }

    log "Dropping tables"; $i = 1
    for ($i = $Env.Tables.Count-1; $i -ge 0; $i--)
    {
        $table = $Env.Tables[$i]
        log "$($i+1)/$($Env.Tables.Count)  $($table.SchemaImported).$($table.NameImported)" -Ident 1

        try {
            #$res = $DestinationDb.ExecuteNonQuery("drop table [$($table.Name)]")
            $res = Invoke-Sqlcmd -ConnectionString $dst -Query "drop table $($table.SchemaImported).$($table.NameImported)"
        } catch {
            if ($_.Exception.InnerException.Number -ne 3701) { throw $_ }   # Cannot drop the table '<table>', because it does not exist or you do not have permission.
        }
    }
}