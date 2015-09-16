PSReddit
===========
This is a set of tools for browsing Reddit using the Powershell command line.

Installation
------------
 * Copy the "PSReddit" folder into your module path. Note: You can find an
appropriate directory by running `$ENV:PSModulePath.Split(';')`.
 * Run `Import-Module PowerReddit` from your PowerShell command prompt.

 Usage
 -----
 
 Register for a Reddit API account here, [Reddit Application Preferences](https://www.reddit.com/prefs/apps), and choose a Script based Application.  Make note of your ClientSecret, ClientID and RedirectURI (which can be anything).
 ![Copy these values](https://github.com/1RedOne/PSReddit/blob/master/img/API.png)
 
###Connecting your Account###
    Connect-RedditAccount -ClientID $clientID -redirectURI $redirectURI -force -ClientSecret $ClientSecret
    #oAuth Window will be displayed 
 
![approve oAuth and away you go!](https://github.com/1RedOne/PSReddit/blob/master/img/Approve.png)
 
 ####Credentials persist in secure storage and are automatically imported when you use a cmdlet in this module!  
 
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

... gets you information about your account including karma and account creation date

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

##Authentication##

Authentication is handled using oAuth via two private function cmdlets, Show-oAuthWindow being the most important of the two.  If you've got another project and you're here because you need some reference for handling oAuth using PowerShell, this will be the cmdlet you want.  It's found in the Module\Private folder.
    Connect-RedditAccount
 
... logs you in, gets information about the logged in user, then logs out.

###To come###

* Making Posts
* imgur uploads
* Your suggestions?
* Multiple Account Support
