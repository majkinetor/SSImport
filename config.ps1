@{
    Defaults = @{
        CreateDb    = $false   # Create destination database if it doesn't exist
        Create      = $true    # Create tables that do not exist
        Truncate    = $false   # Truncate tables
        Drop        = $false   # Drop tables in reverse order
        Import      = $true    # Import data

        # Defaults for source/destination servers
        ServerInstance = '.'
        Database       = 'SSIMPORT_TEST'
        Username       = 'sa'
        Password       = 'P@ssw0rd'
    }

    # Environment HashTable
    aw = @{
        Source = @{ Database = 'AdventureWorks2019' }
        Destination = @{ Database = 'AdventureWorks2019_SSIMPORT6' }

        Tables = @(
            'Person.AddressType'
            'Person.BusinessEntity'
            'Person.ContactType'
            @{
                Name = 'Person.Person'
                Query = 'select TOP 1000 * from []'
            }
            'HumanResources.Department'
            'HumanResources.Shift'
            @{
                Name = 'HumanResources.[Employee]'
                Map = @{
                    'BusinessEntityID' = 'BusinessEntityID'
                    'NationalIDNumber' = 'NationalIDNumber'
                    'LoginID'          = 'LoginID'
                    'OrganizationNode' = 'OrganizationNode'
                #   'OrganizationLevel' = 'OrganizationLevel'  # Removed computed column
                    'JobTitle'         = 'JobTitle'
                    'BirthDate'        = 'BirthDate'
                    'MaritalStatus'    = 'MaritalStatus'
                    'Gender'           = 'Gender'
                    'HireDate'         = 'HireDate'
                    'SalariedFlag'     = 'SalariedFlag'
                    'VacationHours'    = 'VacationHours'
                    'SickLeaveHours'   = 'SickLeaveHours'
                    'CurrentFlag'      = 'CurrentFlag'
                    'rowguid'          = 'rowguid'
                    'ModifiedDate'     = 'ModifiedDate'
                }
            }
            'HumanResources.EmployeePayHistory'
        )

        CreateDb = $true
        Drop = $true
    }
}