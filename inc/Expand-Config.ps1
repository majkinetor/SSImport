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
    }
}