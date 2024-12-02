function create(){
    if (!$Env.Create) { return }

    log "Creating tables"; $i = 1
    foreach ($table in $Env.Tables) {
        log "$i/$($Env.Tables.Count)  $($table.SchemaImported).$($table.NameImported)" -Ident 1 -NoNewLine -PadRight 80
        $i++

        #[string] $tableScript = $tbl.Script() | Select-Object -Skip 2
        $tableScript = Get-TableDdl $SourceDb $table.Name $table.Schema
        if ($table.NameImported -ne $table.Name) {
            $tableScript = $tableScript.Replace($table.Schema, $table.SchemaImported).Replace($table.Name, $table.NameImported)
            if ($table.Map) {
                foreach ($m in $table.Map.Keys) {
                    if ($m -eq $table.Map.$m) { continue }

                    $tableScript = $tableScript.Replace( "[$m]", "[$($table.Map.$m)]" )
                }
            }
        }

        try {
            Invoke-Sqlcmd -ConnectionString $dst -Query "CREATE SCHEMA $($table.SchemaImported)" -ErrorAction Ignore
            $res = Invoke-Sqlcmd -ConnectionString $dst -Query $tableScript
            log "ok" -Raw
        } catch {
            if ($_.Exception.InnerException.Number -ne 2714) { throw $_ }   # There is already an object named '<$table>' in the database.
            log  "ok (exists)" -Raw
        }
    }
}
