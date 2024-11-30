@{
    Defaults = @{
        CreateDb    = $true
        Create      = $true
        Truncate    = $true
        Drop        = $true
        Import      = $true

        ServerInstance = '.'
        Database       = 'PAYS'
        Username       = 'sa'
        Password       = 'P@ssw0rd'

        PreScript  = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT ALL"'
        PostScript = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL"'
    }

    jafin = @{
        Source = @{ ServerInstance = 'sqljafin.mfin.trezor.rs';  Database = 'DBJAFIN';  Username = 'tbass'; Password = $Env:TBASS_PASSWORD}
        Destination = @{ Database = 'DBJAFIN' }
        Tables = 'tPrometna'
    }

    jafintest = @{
        Source = @{ ServerInstance = 'tssjafin19.mfin.trezor.rs';  Database = 'TDBJAFINKJS';  Username = 'mmilic' }

        Tables = @(
            @{ Name = 'tRegistarSK'; Query = "select top 1000 * from []" }
            'tBudzetParametri', 'tParametri', 'tStanjaAnal', 'tStanjaKRT', 'tStanjaPodr', 'tPrometna'
        )
    }

    top = @{
        Source = @{ Database = 'topDB_ATest' }
        Destination = @{ Database = 'topDB_ATest2'}

        Tables = @(
           #@{ Name = 'registry.tBankAccount'; Mapping = @{} }
           'registry.tTreasuryBranch', 'registry.tPaymentCode', 'tPayment', 'tPartner', 'tPaymentOrder', 'security.tOrganization', 'security.tUser'
        )
    }
}