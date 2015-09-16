<#
    Script Variables
#>
    [Microsoft.PowerShell.Commands.WebRequestSession] $script:currentRedditSession;
    [Uri] $script:loginUri = [uri] "http://www.reddit.com/api/login"


<# 
.SYNOPSIS 
    Authenticates to the Reddit API with provided credentials
    
.DESCRIPTION 
    After running this, all cmdlets will run in the scope of the logged in user

.PARAMETER Credential 
    Provide a PSCredential

#>
function Connect-RedditSession
{
[CmdletBinding()]
Param (
    [Parameter(Position=1, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [System.Management.Automation.PSCredential]
    $credential
   )
    
    if( $credential -eq $null )
    {
        $credential = Get-Credential -Message "Enter your Reddit login details:"
    }

    $userName = $credential.GetNetworkCredential().UserName
    $password = $credential.GetNetworkCredential().Password
    
    $parameters = "user={0}&passwd={1}" -f $userName, $password
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($parameters);

    $request = [System.Net.HTTPWebRequest]::Create($script:loginUri) 
    $request.CookieContainer = New-Object System.Net.CookieContainer
    $request.ContentType = "application/x-www-form-urlencoded"
    $request.Method = "POST"
    $request.ContentLength = $buffer.Length;

    $stream = $request.GetRequestStream()
    Try { $stream.Write($buffer, 0, $buffer.Length) }
    Finally{ $stream.Dispose() }

    $response = $request.GetResponse()

    $successCookie = $response.Cookies | Where Name -eq 'reddit_session'
    
    if( $successCookie -eq $null )
    {
    Write-Error -Message "Authentication Failed" `
                -Category PermissionDenied `
                -RecommendedAction "Check username and password"
    }
    else
    {
    Write-Host "Successfully Authenticated user ""$userName"""
    $script:currentRedditSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $script:currentRedditSession.Cookies.Add($successCookie)
    }

    return $script:currentRedditSession
}


<# 
.SYNOPSIS 
    Logs out Reddit session
    
.DESCRIPTION 
    Logs out reddit session by forgetting cookie

#>
function Disconnect-RedditSession
{
[CmdletBinding()]
Param ()

    $script:currentRedditSession = $null

}


<#
.SYNOPSIS 
    Gets a list of Reddit links
    
.DESCRIPTION 
    Uses the Reddit API to get Reddit links from given subreddit(s)

.PARAMETER Name 
    Name of the Subreddit to fetch from. Can be an array.

#>
function Get-RedditLink
{
[CmdletBinding()]
Param (
    [Parameter(Position=1, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [Alias("r","Subreddit")]
    [string[]]
    $Name = 'frontpage'
    )

    # Construct the Uri. Multiple subreddits can be joined with plusses
    $uri = 'http://www.reddit.com/r/{0}.json' -f [string]::Join('+', $Name)

    # Run the RestMethod in the current user context
    $response = (Invoke-RestMethod $uri -WebSession $script:currentRedditSession)

    # This is the listing. Contains before/after for pagination, and links
    $listing  = $response | Where kind -eq 'Listing' | Select -Expand data

    # Links have type "t3" in Reddit API
    $links = $listing.children | Where kind -eq 't3' | select -expand data

    # Return the links with a custom type of [PowerReddit.Link]. We do this so
    # that they can be extended by psxml files, etc.
    $links | %{ $_.PSObject.TypeNames.Insert(0,'PowerReddit.Link'); $_ }

}


<# 
.SYNOPSIS 
    Gets comments of a Reddit link
    
.DESCRIPTION 
    Uses the Reddit API to get comments made on a given link

.PARAMETER id 
    Internal id of the Reddit link

#>
function Get-RedditComment
{
[CmdletBinding()]
Param (
    [Parameter(
        Position = 1,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true
        )]
    [Alias("Link")]
    [string]
    $id
    )

    Process
    {
        $uri = 'http://www.reddit.com/comments/{0}.json' -f $id

        $listings = (Invoke-RestMethod $uri) | Where kind -eq 'Listing'

        # Comments have a type 't1' in Reddit API
        $comments = $listings | %{ $_.data.children } | Where kind -eq 't1' | Select -Expand data

        $comments | %{ $_.PSObject.TypeNames.Insert(0,'PowerReddit.Comment'); $_ }
    }
}


<#
.SYNOPSIS 
    Gets information about the currently logged in user

.PARAMETER redditSession
    An optional session to use (like that returned from Connect-RedditSession)

#>
function Get-RedditUserInfo
{
[CmdletBinding()]
Param (
    [Parameter(
        Position = 1,
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true
        )]
    [Alias("Link")]
    [Microsoft.PowerShell.Commands.WebRequestSession]
    $redditSession
    )

    if ($redditSession -ne $null)
    {
        $thisSession = $redditSession
    }
    elseif ($script:currentRedditSession -ne $null)
    {
        $thisSession = $script:currentRedditSession
    }
    else
    {
        Write-Error -Message "No active session" `
            -Category PermissionDenied `
            -RecommendedAction "Log in or provide a session object" 
        return
    }
    
    $uri = 'http://www.reddit.com/api/me.json'
    $response = (Invoke-RestMethod $uri  -WebSession $thisSession) 
    
    $user = $response | Select -Expand data
    $user | %{ $_.PSObject.TypeNames.Insert(0,'PowerReddit.User'); $_ }
}


<#
Export public functions
#>
Export-ModuleMember -function `
    Get-RedditLink,
    Get-RedditComment,
    Connect-RedditSession,
    Disconnect-RedditSession,
    Get-RedditUserInfo
