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

        ## Not implemented yet
        #PreScriptAll  = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT ALL"'
        #PostScriptAll = 'EXEC sp_MSforeachtable @command1="ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL"'
        #PreScriptEach = ''
        #PostScripEach = ''
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
        Source = @{ ServerInstance = 'top-dev.nil.rs'; Database = 'topDB' }
        Destination = @{ Database = "topDB_Dev_$((Get-Date).ToString('yyyy_mm_dd'))" }

        Tables = @(
           @{
                Name = 'registry.tBankAccount'
                NameImported = 'registry_imported.tBankAccount_DevImport';
                Map = @{
                    Id                       = "Id_imported"
                    Bank                     = "Bank_imported"
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