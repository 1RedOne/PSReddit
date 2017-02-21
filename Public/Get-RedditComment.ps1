<#
.Synopsis
    Gets the comments of a Reddit link, or several.
.DESCRIPTION
    Uses the Reddit API to get comments made on a given link, collection of posts or the id.
.EXAMPLE
    Get-RedditComment -id "3i9psm"
.EXAMPLE
    "https://www.reddit.com/r/redditdev/comments/3i9psm/how_can_i_find_the_id_of_the_original_post_in_a/" | Get-RedditComment
.EXAMPLE
    Get-RedditPost -Name PowerShell | Select-Object -First 1 | Get-RedditComment
#>
function Get-RedditComment
{
[CmdletBinding()]
Param (
    [Parameter(
        Position = 1,
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
    [Alias("Link", "Name")]
    [string]
    $id
    )

    Process
    {
        ## Depending on how we passed the id to the function, we need to
        ## strip some characters.
        switch ($id)
        {
            {($id -like "t3_*")}
            {
                $id = $id -replace "t3_", ""
                break
            }  
            {($id -like "http*")}
            {
                $id = $id.Split("/")[6]
                break
            }
        }

        $uri = 'http://www.reddit.com/comments/{0}.json' -f $id

        Write-Verbose "Sending request to $uri"
        $listings = (Invoke-RestMethod $uri) | Where kind -eq 'Listing'

        # Comments have a type 't1' in Reddit API
        $comments = $listings | ForEach-Object { $_.data.children } | Where-Object kind -eq 't1' | Select-Object -Expand data
        $comments | ForEach-Object { $_.PSObject.TypeNames.Insert(0,'PowerReddit.Comment'); $_ }
    }
}
