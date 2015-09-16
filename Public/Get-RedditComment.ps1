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