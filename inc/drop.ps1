function drop() {
    if (!$Env.Drop) { return }

    log "Dropping tables"; $i = 1
    foreach ($table in $Env.Tables) {
        log "$i/$($Env.Tables.Count)  $($table.Name)" -Ident 1
        $i++

        try {
            #$res = $DestinationDb.ExecuteNonQuery("drop table [$($table.Name)]")
            $res = Invoke-Sqlcmd -ConnectionString $dst -Query "drop table [$($table.Schema)].[$($table.Name)]"
        } catch {
            if ($_.Exception.InnerException.Number -ne 3701) { throw $_ }   # Cannot drop the table '<table>', because it does not exist or you do not have permission.
        }
    }
}