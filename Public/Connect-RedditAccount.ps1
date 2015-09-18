Function Connect-RedditAccount {
[CmdletBinding()]
param(
    $ClientSecret,
    $ClientID,
    $redirectURI,
    [Switch]$force)
    
    $configDir = "$Env:AppData\WindowsPowerShell\Modules\PSReddit\0.1\Config.ps1xml"
    $refreshToken = "$Env:AppData\WindowsPowerShell\Modules\PSReddit\0.1\Config.Refresh.ps1xml"
    #look for a stored password
    

    if (-not (Test-Path $configDir) -or $force){
            if ($force){Write-verbose "`$force detected"}
            #create the file to store our Access Token
            Write-Verbose "cached Access Code not found, or the user instructed us to refresh"
            
            if (-not (Test-Path $refreshToken)){New-item -Force -Path $refreshToken -ItemType file }
            New-item -Force -Path "$configDir" -ItemType File
    
            $guid = [guid]::NewGuid()
            $URL = "https://www.reddit.com/api/v1/authorize?client_id=$clientID&response_type=code&state=$GUID&redirect_uri=$redirectURI&duration=permanent&scope=identity,history,mysubreddits,read,report,save,submit"

            #Display an oAuth login prompt for the user to user authorize our application, returns uri
            Show-OAuthWindow -url $URL

            #attempt to parse $uri to retrieve our AuthCode
            $regex = '(?<=code=)(.*)'
    
            try {$Reddit_authCode  = ($uri | Select-string -pattern $regex).Matches[0].Value}
            catch {Write-Warning "did not receive an authCode, check ClientID and RedirectURi"
                return}  
    
            $global:Reddit_authCode = $Reddit_authCode
            Write-Verbose "Received an authCode, $Reddit_authCode"

            write-debug "Pause here to test value of `$uri"
            Write-Verbose "Exchanging authCode for Access Token"
            
            try { 
                #reddit uses basic auth, which means in PowerShell that we can provide our creds using a credential object
                $secpasswd = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential ($ClientID, $secpasswd)
         
                #retrieve Access Token
                $result = Invoke-RestMethod  https://ssl.reddit.com/api/v1/access_token -Method Post -Body @{client_id=$clientId; state=$guid ; redirect_uri=$redirectURI; grant_type="authorization_code"; code=$Reddit_authCode} -ContentType "application/x-www-form-urlencoded" -ErrorAction STOP -Credential $credential
                 }
          catch {
                Write-Warning "Something didn't work, this is normally caused by an internet flub, try again in a few minutes"
                Write-debug "Test the -body params for the Rest command"
            }
            
            Write-Debug 'go through the results of $result, looking for our token'
            if ($result.access_token){
                 Write-Output "Updated Authorization Token"
                 $global:PSReddit_accessToken = $result.access_token}
            
            Write-Verbose "Storing token in $configDir"
            #store the token
            $password = ConvertTo-SecureString $PSReddit_accessToken -AsPlainText -Force
            $password | ConvertFrom-SecureString | Export-Clixml $configDir -Force

            Write-verbose "Storing refresh token in $refreshToken"
            $password = ConvertTo-SecureString $result.refresh_token -AsPlainText -Force
            $password | ConvertFrom-SecureString | Export-Clixml $refreshToken -Force
            
        }
        else{
            #if the user did not specify -Force, or if the file path for a stored token already exists
            Write-Verbose "We're looking for a stored token in $configDir"
            try {
                 $password = Import-Clixml -Path $configDir -ErrorAction STOP | ConvertTo-SecureString
                 $refreshToken = Import-Clixml -Path $refreshToken -ErrorAction STOP | ConvertTo-SecureString
                 }
          catch {
            Write-Warning "Corrupt Password file found, rerun with -Force to fix this"
            BREAK
           }
           
            Get-DecryptedValue -inputObj $password -name PSReddit_accessToken
            Get-DecryptedValue -inputObj $refreshToken -name PSReddit_refreshToken
            <#
            $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($password)
            $result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
            $global:PSReddit_accessToken = $result #>
            'Found cached Cred'
            continue
        }

}