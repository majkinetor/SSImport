function Expand-Config {
    foreach ($environment in $Config.Keys.Where( {$_ -ne 'Defaults'} )) {
        $env = $Config.$environment
        foreach ($key in $Config.Defaults.Keys) {
            $defaultValue = $Config.Defaults.$key

            if ($key -in 'ServerInstance', 'Database', 'Username', 'Password' ) {
                foreach ($target in 'Source', 'Destination') {
                    if ($null -ne $env.$target.$key) { continue }
                    if ($null -eq $env.$target) { $env.$target = @{} }
                    $env.$target.$key = $defaultValue
                }
                continue
            }

            if ($null -ne $Config.$env.$key) { continue }
            $env.$key = $defaultValue
        }

        $env.Tables = foreach ($table in $env.Tables) {
            [hashtable] $t = $table -is [string] ? @{ Name = $table } : $table

            $a = $t.Name -split '\.'
            if ($a[1]) { $t.Schema = $a[0]; $t.Name = $a[1]} else { $t.Schema = 'dbo'; $t.Name = $a[0] }

            $t.Schema = "[" + ($t.Schema -replace "\[|\]") + "]"
            $t.Name   = "[" + ($t.Name   -replace "\[|\]") + "]"
            if (!$t.Query) { $t.Query = "select * from []" }

            if (!$t.NameImported) { $t.NameImported = $t.Name }
            $a = $t.NameImported -split '\.'
            if ($a[1]) { $t.SchemaImported = $a[0]; $t.NameImported = $a[1]} else { $t.SchemaImported = $t.Schema; $t.Name = $a[0] }

            $t.SchemaImported = "[" + ($t.SchemaImported -replace "\[|\]") + "]"
            $t.NameImported   = "[" + ($t.NameImported   -replace "\[|\]") + "]"

            $t.Query = $t.Query.Replace('[]', "$($t.Schema).$($t.Name)")
            $t
        }
    }
}