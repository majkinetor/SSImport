function truncate() {
    if (!$Env.Truncate -or $Env.Drop) { return }

    log "Truncating tables"; $i = 1
    foreach ($table in $Env.Tables) {
        log "$i/$($Env.Tables.Count)  $($table.Name)" -Ident 1
        $i++

        $res = Invoke-Sqlcmd -ConnectionString $dst -Query "truncate table $($table.SchemaImported).$($table.NameImported)"
    }
}