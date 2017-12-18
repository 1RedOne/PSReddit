<#
.Synopsis
   Use this cmdlet to connect to your Reddit account from PowerShell
.DESCRIPTION
   Use this cmdlet to connect to your Reddit account from PowerShell.You'll first need to register for an Register for a Reddit API account here, https://www.reddit.com/prefs/apps, and choose a Script based Application.  
   
   Make note of your ClientSecret, ClientID and RedirectURI (which can be anything).  This cmdlet displays a login window to allow a user to provision access to their account by means of oAuth.  
   
   The permissions requested are: identity, history, mysubreddits, read, report, save, submit
.EXAMPLE
   Connect-RedditAccount -ClientID $ClientID -ClientSecret $ClientSecret -RedirectURI $RedirectURI
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   You'll first need to register for an Register for a Reddit API account here, https://www.reddit.com/prefs/apps, and choose a Script based Application.  Make note of your ClientSecret, ClientID and RedirectURI (which can be anything).
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
.LINK
   https://www.reddit.com/dev/api
    For Reference for the API
   https://github.com/1RedOne/PSReddit/
    The project homepage on GitHub
   
#>
Function Connect-RedditAccount {
[CmdletBinding()]
param(
    $ClientSecret,
    $ClientID,
    $redirectURI,
    [Switch]$force)
    
    $configDir = "$Env:AppData\WindowsPowerShell\Modules\PSReddit\0.1\Config.ps1xml"
    $refreshTokenPath = "$Env:AppData\WindowsPowerShell\Modules\PSReddit\0.1\Config.Refresh.ps1xml"
    #look for a stored password
    

    if (-not (Test-Path $configDir) -or $force){
            if ($force){Write-verbose "`$force detected"}
            #create the file to store our Access Token
            Write-Verbose "cached Access Code not found, or the user instructed us to refresh"
            
            if (-not (Test-Path $refreshTokenPath)){New-item -Force -Path $refreshTokenPath -ItemType file }
            New-item -Force -Path "$configDir" -ItemType File
    
            $guid = [guid]::NewGuid()
            $URL = "https://www.reddit.com/api/v1/authorize?client_id=$clientID&response_type=code&state=$GUID&redirect_uri=$redirectURI&duration=permanent&scope=identity,history,mysubreddits,read,report,privatemessages,save,submit"

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
            $password = ConvertTo-SecureString $result.access_token -AsPlainText -Force
            $password | ConvertFrom-SecureString | Export-Clixml $configDir -Force

            Write-verbose "Storing refresh token in $refreshTokenPath"
            $refresh = ConvertTo-SecureString $result.refresh_token -AsPlainText -Force
            $refresh | ConvertFrom-SecureString | Export-Clixml $refreshTokenPath -Force
            
        }
        else{
            #if the user did not specify -Force, or if the file path for a stored token already exists
            Write-Verbose "We're looking for a stored token in $configDir"
            try {
                 $password = Import-Clixml -Path $configDir -ErrorAction STOP | ConvertTo-SecureString
                 $refreshToken = Import-Clixml -Path $refreshTokenPath -ErrorAction STOP | ConvertTo-SecureString
                 }
          catch {
            Write-Warning "Corrupt Password file found, rerun with -Force to fix this"
            BREAK
           }
           
            Get-DecryptedValue -inputObj $password -name PSReddit_accessToken
            Get-DecryptedValue -inputObj $refreshToken -name PSReddit_refreshToken
            
            'Found cached Cred'
            continue
        }

}