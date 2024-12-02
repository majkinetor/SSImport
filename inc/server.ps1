function Get-Server($ServerInstance, $Username, $Password) {
    $connection = New-Object -TypeName Microsoft.SqlServer.Management.Common.ServerConnection -ArgumentList $ServerInstance
    $connection.LoginSecure = $false
    $connection.Login = $Username
    $connection.Password = $Password

    New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $connection
}

function Get-TableDdl($Database, $TableName, $Schema = 'dbo') {
    $options = New-Object -TypeName Microsoft.SqlServer.Management.Smo.ScriptingOptions
    $options.DriAll          = $true
    $options.DriAllKeys      = $true
    $options.DriForeignKeys  = $true
    $options.DriNonClustered = $true
    $options.Indexes         = $true
    $options.IncludeHeaders  = $true
    $options.SchemaQualify   = $true

    $res = $Database.Tables.Item((c $TableName), (c $Schema)).Script($options)
    $res -join "`n"
}

function c($s) { $s.Replace('[', '').Replace(']', '') }

function Get-MsSqlConString(
    [string] $ServerInstance,
    [string] $Database,
    [string] $Username,
    [string] $Password,
    [int]    $Timeout = 30,
    [switch] $Encrypt,
    [switch] $TrustServerCertificate)
{
    "Server={0}; Database={1}; User id={2}; Password={3}; Encrypt={4}; TrustServerCertificate={5}; Connection Timeout={6}" -f $ServerInstance, $Database, $Username, $Password, $Encrypt, $TrustServerCertificate, $Timeout
}