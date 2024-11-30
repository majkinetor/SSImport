
function Get-SQLTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [HashTable] $Source,

        [Parameter(Mandatory=$true)]
        [HashTable] $Destination,

        [Parameter(Mandatory=$true)]
        [string[]] $Tables,

        [Parameter(Mandatory=$false)]
        [int] $BulkCopyBatchSize = 10000,

        [Parameter(Mandatory=$false)]
        [int] $BulkCopyTimeout = 600
    )

    $srcConnString   = Get-MsSqlConString @Source
    $dstConnString   = Get-MsSqlConString @Destination

    $sourceSQLServer = New-Object Microsoft.SqlServer.Management.Smo.Server $Source.Server
    $sourceDB        = $sourceSQLServer.Databases[$Source.Database]
    $sourceConn      = New-Object System.Data.SqlClient.SQLConnection($srcConnString)
    $sourceConn.Open()

    foreach($table in $sourceDB.Tables)
    {
        $tableName = $table.Name
        $schemaName = $table.Schema
        $tableAndSchema = "$schemaName.$tableName"

        if ($Tables.Contains($tableAndSchema))
        {
            $Tablescript = ($table.Script() | Out-String)
            $Tablescript

            Invoke-Sqlcmd -ServerInstance $Config.Destination.Server -Database $Config.Destination.Database -Query $Tablescript
            $sql = "SELECT * FROM $tableAndSchema"

             $sqlCommand = New-Object system.Data.SqlClient.SqlCommand($sql, $srcConnString)
            [System.Data.SqlClient.SqlDataReader] $sqlReader = $sqlCommand.ExecuteReader()
            $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($dstConnString, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
            $bulkCopy.DestinationTableName = $tableAndSchema
            $bulkCopy.BulkCopyTimeOut = $BulkCopyTimeout
            $bulkCopy.BatchSize = $BulkCopyBatchSize
            $bulkCopy.WriteToServer($sqlReader)
            $sqlReader.Close()
            $bulkCopy.Close()
        }
    }
    $sourceConn.Close()

}