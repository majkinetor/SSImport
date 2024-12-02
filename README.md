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

List of tables to import to the destination database is specified in the `Tables` environment option. It can be either be array of strings or HashTables. HashTable allows for configuration of detailed table import options (like `Query`). Tables are processed in the order specified.

When using string, table is specified as `table_name` or `schema.table_name` (and any variant using `[]`). The simple string syntax is fast to use, but doesn't allow detailed import configuration.

With HashTable, the following import options can be used:

|     Option     |                     Description                     |      Default       |
| -------------- | --------------------------------------------------- | ------------------ |
| `Name`         | Name of the source table (with optional schema)     |                    |
| `NameImported` | Rename the destination table (with optional schema) | `Name`             |
| `Map`          | Map of the source to destination table columns      | map all by name    |
| `Query`        | Query used to select data from the table            | `select * from []` |


## Example config

```powershell
@{
    Defaults = @{
        CreateDb    = $false   # Create destination database if it doesn't exist
        Create      = $true    # Create tables
        Truncate    = $false   # Truncate tables
        Drop        = $false   # Drop tables
        Import      = $false   # Import data

        # Defaults for source/destination servers
        ServerInstance = '.'
        Database       = 'SSIMPORT_TEST'
        Username       = 'sa'
        Password       = 'P@ssw0rd'
    }

    # environment HashTable
    remote_db = @{
        Source      = @{ Database = 'REMOTE_DB'; ServerInstance = 'remote-db.example.com';  Username = 'remote_user'; Password = $Env:PASSWORD }
        Destination = @{ Database = 'REMOTE_DB_SSIMPORT' }

        Tables = @(
            'table1', 'schema.table2', '[schema].[table3]',
            @{
                Name = 'table4'
                Query = 'select TOP 1000 * from [] order by CreatedDate desc'
            },
            @{
                Name = 'schema.table5'
                NameImported = 'schema_imported.table5_imported'
            }
        )

        CreateDb = $true
        Drop     = $true
        Import   = $true
    }
}
```

[Import Data]: https://learn.microsoft.com/en-us/sql/integration-services/import-export-data/start-the-sql-server-import-and-export-wizard?view=sql-server-ver16