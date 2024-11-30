function create(){
    if (!$Env.Create) { return }

    log "Creating tables"; $i = 1
    foreach ($table in $Env.Tables) {
        log "$i/$($Env.Tables.Count)  $($table.Name)" -Ident 1 -NoNewLine -PadRight 60
        $i++

        #[string] $tableScript = $tbl.Script() | Select-Object -Skip 2
        $tableScript = Get-TableDdl $SourceDb $table.Name $table.Schema
        try {
            Invoke-Sqlcmd -ConnectionString $dst -Query "CREATE SCHEMA $($table.Schema)" -ErrorAction Ignore
            $res = Invoke-Sqlcmd -ConnectionString $dst -Query $tableScript
            log "ok" -Raw
        } catch {
            if ($_.Exception.InnerException.Number -ne 2714) { throw $_ }   # There is already an object named '<$table>' in the database.
            log  "ok (exists)" -Raw
        }
    }
}