# ssimport

SQL Server import tool.

## Usage

The script uses `config.ps1` to define environments and default values.

Each environment is a `HashTable` containing following arguments:

|    Option     |       Type       |                               Description                                |
| ------------- | ---------------- | ------------------------------------------------------------------------ |
| `Source`      | HashTable        | Source db connection  (ServerInstance, Database, Username, Password)     |
| `Destination` | HashTable        | Destination db connection (ServerInstance, Database, Username, Password) |
| `Tables`      | Array[HashTable] | Array of tables to copy from the source to destination database          |
| `CreateDb`    | Bool             | Create destination database if it doesn't exist                          |
| `Create`      | Bool             | Create tables on the destination                                         |
| `Truncate`    | Bool             | Truncate destination tables (unless Drop is used)                        |
| `Drop`        | Bool             | Drop destination tables on start                                         |
| `Import`      | Bool             | Copy data from source to destination database                            |

### Table array

List of tables can be either strings or HashTables if detailed table setup is required.

Table options:

|     Option     |                  Description                   |      Default       |
| -------------- | ---------------------------------------------- | ------------------ |
| `Name`         | Name of the source table (with schema)         |                    |
| `NameImported` | Rename the destination table (with schema)     | `Name`             |
| `Map`          | Map of the source to destination table columns | map all by name    |
| `Query`        | Query used to select data from the table       | `select * from []` |