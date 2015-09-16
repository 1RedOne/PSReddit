[CmdletBinding()]
#Get public and private function definition files.
    $PublicFunction  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude *tests* -ErrorAction SilentlyContinue )
    $PrivateFunction = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude *tests* -ErrorAction SilentlyContinue )
    
#Dot source the files
    Foreach($import in @($PublicFunction + $PrivateFunction))
    {
        write-verbose "importing $import"
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

    #Initialize our variables.  I know, I know...

    $configDir = "$Env:AppData\WindowsPowerShell\Modules\PSReddit\0.1\Config.ps1xml"
    $refreshToken = "$Env:AppData\WindowsPowerShell\Modules\PSReddit\0.1\Config.Refresh.ps1xml"


    Try
    {
        #Import the config
        $password = Import-Clixml -Path $configDir -ErrorAction STOP | ConvertTo-SecureString
        $refreshToken = Import-Clixml -Path $refreshToken -ErrorAction STOP | ConvertTo-SecureString
     }
    catch {
    Write-Warning "Corrupt Password file found, rerun with -Force to fix this"
    BREAK
    }
           
    Get-DecryptedValue -inputObj $password -name PSReddit_accessToken
    Get-DecryptedValue -inputObj $refreshToken -name PSReddit_refreshToken

    

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

Export-ModuleMember -Function $PublicFunction.Basename