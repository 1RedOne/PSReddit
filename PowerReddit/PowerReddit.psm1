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

    # This is the listing. Contains before/after for pagination, and links
    $listing = (Invoke-RestMethod $uri) | Where kind -eq 'Listing' | Select -Expand data

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


Export-ModuleMember -function Get-RedditLink, Get-RedditComment
