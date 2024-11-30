@{
    Defaults = @{
        CreateDb    = $true
        Create      = $true
        Truncate    = $true
        Recreate    = $false
        Data        = $true

        ServerInstance = '.'
        Database       = 'PAYS'
        Username       = 'sa'
        Password       = 'P@ssw0rd'

        PreScript  = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT ALL"'
        PostScript = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL"'
    }

    jafintest = @{
        Source = @{ ServerInstance = 'tssjafin19.mfin.trezor.rs';  Database = 'TDBJAFINKJS';  Username = 'mmilic' }

        Tables = @(
            @{ Name = 'tRegistarSK'; Query = "select top 1000 * from []" }
            'tBudzetParametri', 'tParametri', 'tStanjaAnal', 'tStanjaKRT', 'tStanjaPodr'
        )
    }

    top = @{
        Source = @{ Database = 'topDB' }

        Tables = @(
           @{
                Name = 'registry.tBankAccount'
                Mapping = @{}
            }
           'registry.tTreasuryBranch', 'registry.tPaymentCode'
        )
    }
}