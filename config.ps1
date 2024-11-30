@{
    Defaults = @{
        CreateDb    = $true     # Create destination database if it doesn't exist
        Create      = $true     # Create tables
        Truncate    = $true     # Truncate tables
        Drop        = $true     # Drop tables
        Import      = $true     # Import data

        # Defaults for source/destination servers
        ServerInstance = '.'
        Database       = 'PAYS'
        Username       = 'sa'
        Password       = 'P@ssw0rd'

        #PreScript  = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT ALL"'
        #PostScript = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL"'
    }

    jafin = @{
        Source = @{ ServerInstance = 'sqljafin.mfin.trezor.rs';  Database = 'DBJAFIN';  Username = 'sa'; Password = $Env:PASSWORD }
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
           @{
                Name = 'registry.tBankAccount'
                Map = @{
                    Id                       = "Id"
                    Bank                     = "Bank"
                    Number                   = "Number"
                    ControlNumber            = "ControlNumber"
                    # Group                    = "Group"
                    OrganizationId           = "OrganizationId"
                    Name                     = "Name"
                    NameTranslit             = "NameTranslit"
                    Activity                 = "Activity"
                    Status                   = "Status"
                    OrganizationalUnitNumber = "OrganizationalUnitNumber"
                    Treasury                 = "Treasury"
                    Type                     = "Type"
                    CreatedDate              = "CreatedDate"
                    CreatedUserId            = "CreatedUserId"
                    ModifiedDate             = "ModifiedDate"
                    ModifiedUserId           = "ModifiedUserId"
                }
           }
           'registry.tTreasuryBranch', 'registry.tPaymentCode', 'tPayment', 'tPartner', 'tPaymentOrder', 'security.tOrganization', 'security.tUser'
        )
    }
}