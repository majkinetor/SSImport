# ssimport

This script imports tables from one SQL Server to another. It is similar to the SQL Server Management Studio's [Import Data] task.

The script can be quickly run after tweaking the parameters in the configuration file, which allows for fast experimentation.

## Usage

1. Add environments and their parameters in the configuration file `config.ps1`
1. Run the script with given environment name (or list of names)

```
./ssimport -Environment TestDB
```

## Configuration

The script uses `config.ps1` to obtain environments and default values. Configuration script returns `HashTable` with all the options.

Each environment is a `HashTable` containing the following arguments:

|    Option     |       Type       |                                  Description                                   |
| ------------- | ---------------- | ------------------------------------------------------------------------------ |
| `Source`      | HashTable        | Source database connection  (ServerInstance, Database, Username, Password)     |
| `Destination` | HashTable        | Destination database connection (ServerInstance, Database, Username, Password) |
| `Tables`      | Array[HashTable] | Array of tables to copy from the source to the destination database            |
| `CreateDb`    | Bool             | Create destination database if it doesn't exist                                |
| `Create`      | Bool             | Create tables on the destination database, ignore any existing ones            |
| `Truncate`    | Bool             | Truncate tables on the destination database (ignored if `Drop` is used)        |
| `Drop`        | Bool             | Drop tables in the destination database in reverse                             |
| `Import`      | Bool             | Copy data from the source to the destination database                          |

If specific option is not set in the environment, script will use the option in the  `Defaults` section.

### Table array

List of tables to import to the destination database is specified in the `Tables` environment option. It can either be array of strings or HashTables. HashTable allows for configuration of detailed table import options (like `Query`). Tables are processed in the order specified.

With string, table is specified as `table_name` or `schema.table_name` (and any variant using `[]`). The simple string syntax is fast to use, but doesn't allow detailed import options.

With HashTable, the following import options can be used:

|     Option     |                     Description                      |      Default       |
| -------------- | ---------------------------------------------------- | ------------------ |
| `Name`         | Name of the source table (with optional schema)      |                    |
| `NameImported` | Name of the destination table (with optional schema) | `Name`             |
| `Map`          | Map of the source to destination table columns       | map all by name    |
| `Query`        | Query used to select data from the table             | `select * from []` |


## Example config

The following example shows configuration with one environment `aw`, for the [AdventureWorks](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure) sample database.

```powershell
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
        Destination = @{ Database = 'AdventureWorks2019_SSIMPORT' }

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
```

Output:

```
01:20:19 [00:00:00]    Environment: aw
01:20:19 [00:00:00]      Source: . AdventureWorks2019
01:20:19 [00:00:00]      Destination: . AdventureWorks2019_SSIMPORT
01:20:29 [00:00:10]    CREATING DATABASE AdventureWorks2019_SSIMPORT
01:20:29 [00:00:10]    Dropping tables
01:20:29 [00:00:10]      8/8  [HumanResources].[EmployeePayHistory]
01:20:29 [00:00:10]      7/8  [HumanResources].[Employee]
01:20:29 [00:00:10]      6/8  [HumanResources].[Shift]
01:20:29 [00:00:10]      5/8  [HumanResources].[Department]
01:20:29 [00:00:10]      4/8  [Person].[Person]
01:20:29 [00:00:10]      3/8  [Person].[ContactType]
01:20:29 [00:00:10]      2/8  [Person].[BusinessEntity]
01:20:29 [00:00:10]      1/8  [Person].[AddressType]
01:20:29 [00:00:10]    Creating tables
01:20:29 [00:00:10]      1/8  [Person].[AddressType]                                                     ok
01:20:29 [00:00:10]      2/8  [Person].[BusinessEntity]                                                  ok
01:20:29 [00:00:10]      3/8  [Person].[ContactType]                                                     ok
01:20:29 [00:00:10]      4/8  [Person].[Person]                                                          ok
01:20:29 [00:00:10]      5/8  [HumanResources].[Department]                                              ok
01:20:29 [00:00:10]      6/8  [HumanResources].[Shift]                                                   ok
01:20:29 [00:00:10]      7/8  [HumanResources].[Employee]                                                ok
01:20:29 [00:00:10]      8/8  [HumanResources].[EmployeePayHistory]                                      ok
01:20:29 [00:00:10]    Importing data
01:20:29 [00:00:10]      1/8  [Person].[AddressType]                                                     6         ok
01:20:29 [00:00:10]      2/8  [Person].[BusinessEntity]                                                  20777     ok
01:20:29 [00:00:10]      3/8  [Person].[ContactType]                                                     20        ok
01:20:29 [00:00:10]      4/8  [Person].[Person]                                                          1000      ok
01:20:30 [00:00:10]      5/8  [HumanResources].[Department]                                              16        ok
01:20:30 [00:00:10]      6/8  [HumanResources].[Shift]                                                   3         ok
01:20:30 [00:00:11]      7/8  [HumanResources].[Employee]                                                290       ok
01:20:30 [00:00:11]      8/8  [HumanResources].[EmployeePayHistory]                                      316       ok
01:20:30 [00:00:11]    done aw
```

[Import Data]: https://learn.microsoft.com/en-us/sql/integration-services/import-export-data/start-the-sql-server-import-and-export-wizard?view=sql-server-ver16