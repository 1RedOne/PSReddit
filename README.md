PowerReddit
===========
This is a set of tools for browsing Reddit using the Powershell command line.

Installation
------------
 * Copy the "PowerReddit" folder into your module path. Note: You can find an
appropriate directory by running `$ENV:PSModulePath.Split(';')`.
 * Run `Import-Module PowerReddit` from your PowerShell command prompt.

 Usage
 -----

###Links###

    Get-RedditLink

... gets you a nicely formatted table of the current front page links.

    Get-RedditLink -r Powershell, Sysadmin

... does the same but for the subreddits listed.

    Get-RedditLink -r Powershell | Where is_self | Format-List title, selftext | Out-Host -Paging

... will let you read the front-page self posts from the Powershell subreddit,
in a nicely paginated format.

    $top =  Get-RedditLink | Sort -Descending score 
    $top[0].OpenUrl()

... will open the link with the top score on the front page in your default
browser

###Comments###

    Get-RedditLink | Get-RedditComment

... gets you all the top-level comments of all the posts on the front page

    $top[0] | Get-RedditComment

... gets you the comments on just that top post
