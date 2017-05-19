<#
.Synopsis
    Retrieve a listing of the top 50 posts by popularity in a given subreddit.  Supports -Subreddit to specify a particular subreddit
.DESCRIPTION
    Currently the objects are a bit boned, and you can't get into too much detail, so that's no good.  Trust me when I say it will get better.
.EXAMPLE
    Get-RedditPost    
ups          : 4819
title        : You know what.. Fuck you!
url          : http://i.imgur.com/ln1PIuI.gifv
name         : t3_3lfds5
permalink    : /r/Unexpected/comments/3lfds5/you_know_what_fuck_you/
Created Date : 3 hours ago

ups          : 5215
title        : It must have been a rough divorce
url          : http://imgur.com/fXdbGtd.jpeg
name         : t3_3lfbd9
permalink    : /r/funny/comments/3lfbd9/it_must_have_been_a_rough_divorce/
Created Date : 2 hours ago
.EXAMPLE
    Get-RedditPost -Name PowerShell | select -First 5


ups       : 4
title     : List All printers that were /ga from PrintUI
url       : http://www.reddit.com/r/PowerShell/comments/3lgj6a/list_all_printers_that_were_ga_from_printui/
name      : t3_3lgj6a
created   : 1442627254.0
permalink : /r/PowerShell/comments/3lgj6a/list_all_printers_that_were_ga_from_printui/

ups       : 10
title     : Combine directories.
url       : http://www.reddit.com/r/PowerShell/comments/3lf9ny/combine_directories/
name      : t3_3lf9ny
created   : 1442607409.0
permalink : /r/PowerShell/comments/3lf9ny/combine_directories/
.EXAMPLE
    Get-RedditPost -Name PowerShell | select -First 1 | Get-RedditPostComments

    This will eventually work
#>
Function Get-RedditPost {
[CmdletBinding()]
Param (
    [Parameter(Position=1, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [Alias("r","Subreddit")]
    [string[]]
    $Name = 'all',
    [Parameter(
        Position = 0,
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true
        )]
    [Alias("Link")]
    $accessToken=$Global:PSReddit_accessToken
    )
    #needs to be updated to reflect properties on line 36, also need to add new type to .ps1xml file for this
    $defaultDisplaySet = 'ID','name','Created Date','comment_karma','link_karma','gold_credits'
    # Construct the Uri. Multiple subreddits can be joined with plusses
    #$uri = 'http://www.reddit.com/r/{0}.json' -f [string]::Join('+', $Name)

    $uri = "https://oAuth.reddit.com/r/$Name/hot" ; 
    try {$response = (Invoke-RestMethod $uri -Headers @{"Authorization" = "bearer $accessToken"} -ErrorAction STOP) }
    catch{write-warning "Authentication failed, we should do something here"}

    $response.data.children.data | Select ups,Title,URL,name,created,permalink

    #Figure out the age of a post
    write-debug "figure out select logic for age of post"
    
    $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    $now = get-date
    $created = $origin.AddSeconds($response.created)

    $response.data.children.data | select -ExcludeProperty created* -Property ups,Title,URL,name,created,permalink,@{Name="Created Date";exp={
      "$($origin.AddSeconds($_.created) - $now | select -expandProperty Hours) hours ago"
      } 
    }

    
    <#
    Write-debug "test out response"
    # This is the listing. Contains before/after for pagination, and links
    $listing  = $response | Where kind -eq 'Listing' | Select -Expand data

    # Links have type "t3" in Reddit API
    $links = $listing.children | Where kind -eq 't3' | select -expand data

    # Return the links with a custom type of [PowerReddit.Link]. We do this so
    # that they can be extended by psxml files, etc.
    $links | %{ $_.PSObject.TypeNames.Insert(0,'PowerReddit.Link'); $_ }

    #>
}