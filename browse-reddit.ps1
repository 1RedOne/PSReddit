# Browse-Reddit Script

#Invoke-RestMethod http://www.reddit.com/.rss | Select Title, Link
$i=1
$frontpage=Invoke-RestMethod http://www.reddit.com/.rss
$frontpage | Select-Object @{name = 'Article Number'; expression = {$i;$global:i++;}}, @{name = 'Name'; expression = {$_.Title;}}

$article = Read-host "Select Article to read:"
$article=$article-1
$frontpage[$article].Title

