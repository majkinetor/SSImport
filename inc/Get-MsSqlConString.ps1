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