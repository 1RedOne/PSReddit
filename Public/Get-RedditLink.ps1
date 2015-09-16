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