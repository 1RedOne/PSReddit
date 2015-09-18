



<#
POST /api/submitsubmit



Submit a link to a subreddit.

Submit will create a link or self-post in the subreddit sr with the title title. If kind is "link", then url is expected to be a valid URL to link to. Otherwise, text, if present, will be the body of the self-post.

If a link with the same URL has already been submitted to the specified subreddit an error will be returned unless resubmit is true. extension is used for determining which view-type (e.g. json, compact etc.) to use for the redirect that is generated if the resubmit error occurs.


api_type

the string json
 

captcha

the user's response to the CAPTCHA challenge
 

extension

extension used for redirects
 

iden

the identifier of the CAPTCHA challenge
 

kind

one of (link, self)
 

resubmit

boolean value
 

sendreplies

boolean value
 

sr

name of a subreddit
 

text

raw markdown text
 

title

title of the submission. up to 300 characters long
 

uh / X-Modhash header

a modhash
 

url

a valid URL
 

#>