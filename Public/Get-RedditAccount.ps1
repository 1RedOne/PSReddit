<#
.SYNOPSIS 
    Gets information about the currently logged in user
.Description
    After you've connected using Connect-RedditAccount, you can use this cmdlet to get information about the currently logged in user
.PARAMETER redditSession
    An optional session to use (like that returned from Connect-RedditSession)
.Example
Get-RedditAccount

name               : 1RedOne
hide_from_robots   : False
gold_creddits      : 0
link_karma         : 2674
comment_karma      : 19080
over_18            : True
is_gold            : False
is_mod             : False
gold_expiration    : 
has_verified_email : True
inbox_count        : 2
Created Date       : 1/20/2010 6:44:21 PM
.LINK
https://github.com/1RedOne/PSReddit
#>
function Get-RedditAccount
{
[CmdletBinding()]
Param (
    [Parameter(
        Position = 1,
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true
        )]
    [Alias("Link")]
    $accessToken=$Global:PSReddit_accessToken
    )
    
    
    $defaultDisplaySet = 'ID','name','Created Date','comment_karma','link_karma','gold_credits'

    #Create the default property display set
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    
    $uri = 'https://oAuth.reddit.com/api/v1/me'
    try {$response = (Invoke-RestMethod $uri -Headers @{"Authorization" = "bearer $accessToken"}) }
   catch{write-warning "Authentication failed, we should do something here"}
    
    $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    $created = $origin.AddSeconds($response.created)

    $response | select -ExcludeProperty created* -Property *,@{Name="Created Date";exp={$created}}

    $response.PSObject.TypeNames.Insert(0,'PSReddit.User')
    $response | Add-Member MemberSet PSStandardMembers $PSStandardMembers
    
}
