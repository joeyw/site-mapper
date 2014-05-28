# SiteMapper

Single domain name website internal link and static asset mapper.

SiteMapper crawls websites and captures all the pages for a single domain name.
It stores the static assets used and the urls that use them. It gathers links
between pages for the same domain name.

# Getting Started

SiteMapper is developed on Ruby 2.1.0

Install project dependences with:

`script/bootstrap`

# Experiment with the console

`script/console`

Crawl www.digitalocean.com:

```irb
# Crawl a url, currently you must include the full url including http.
# It currently works for a single hostname only, so if domain.com redirects
# to www.domain.com you need to enter the later or you will end up with an
# empty result.
site_map = SiteMapper.map 'http://www.digitalocean.com'

# Get a hash representation
site_map.to_h

# Convert to json
require 'json'
site_map.to_h.to_json
```

A SiteMap is returned from `.map` and has the methods `.site_url`, `.pages`,
and `.assets`.

`.pages` returns a hash with urls as keys.  Each page consists of a hash and
contains the following keys: `<Array> :outbound_links Other pages the page
links to`, `<Array> :inbound_links Urls of other pages that link to this page`,
`<Array> :assets List of assets used on this page`.

`.assets` returns a hash with urls as keys. Each asset url is a hash containing
a key `<Array> :dependent_urls Pages that include the asset url`.

### Sample json output of results

```json
{
   "site_url":"http://wynnnetherland.com",
   "pages":{
      "http://wynnnetherland.com/":{
         "outbound_links":[
            "http://wynnnetherland.com/",
            "http://wynnnetherland.com/archives",
            "http://wynnnetherland.com/about",
            "http://wynnnetherland.com/journal/radio-silence-and-the-remote-worker",
            "http://wynnnetherland.com/talks/refactoring-with-science",
            "http://wynnnetherland.com/linked/2014031301/video-refactoring-github-with-science",
            "http://wynnnetherland.com/journal/atom-invites-available"
         ],
         "inbound_links":[
            "http://wynnnetherland.com/",
            "http://wynnnetherland.com/archives",
            "http://wynnnetherland.com/about",
            "http://wynnnetherland.com/linked/2014031301/video-refactoring-github-with-science",
            "http://wynnnetherland.com/journal/atom-invites-available",
            "http://wynnnetherland.com/linked/2014022502/aesthetics",
            "http://wynnnetherland.com/linked/2014022501/only-9-s-web-developers-remember-this",
            "http://wynnnetherland.com/journal/thanks-jim"
         ],
         "assets":[
            "http://dfiuq0wxrdccr.cloudfront.net/assets/application-22a27f9703a58abd9ed128f994f41f92.css",
            "http://feeds.feedburner.com/wynn",
            "http://dfiuq0wxrdccr.cloudfront.net/assets/apple-touch-icon-114x114-precomposed-ba4620cb8daa78c2f2142287f5d934e5.png",
            "http://dfiuq0wxrdccr.cloudfront.net/assets/application-26302d2a6543346b9b0ed5c9466e5b81.js"
         ]
      },
      "http://wynnnetherland.com/journal/radio-silence-and-the-remote-worker":{
         "outbound_links":[
            "http://wynnnetherland.com/",
            "http://wynnnetherland.com/archives",
            "http://wynnnetherland.com/about",
            "http://wynnnetherland.com/journal/github-is-a-fish-bowl",
            "http://wynnnetherland.com/journal/tmux-stateful-workspaces-for-frictionless-context-switching",
            "http://wynnnetherland.com/journal/putting-the-emote-in-remote-work",
            "http://wynnnetherland.com/journal/flint-lint-your-project-for-sources-of-contributor-friction"
         ],
         "inbound_links":[
            "http://wynnnetherland.com/",
            "http://wynnnetherland.com/archives",
            "http://wynnnetherland.com/journal/radio-silence-and-the-remote-worker"
         ],
         "assets":[
            "http://dfiuq0wxrdccr.cloudfront.net/assets/application-22a27f9703a58abd9ed128f994f41f92.css",
            "http://feeds.feedburner.com/wynn",
            "http://fonts.googleapis.com/css?family=Droid+Sans:400,700|Bitter:400,700,400italic|Open+Sans:300italic,400italic,700italic,400,300,700",
            "https://plus.google.com/+WynnNetherland/posts",
            "http://platform.twitter.com/widgets.js",
            "http://dfiuq0wxrdccr.cloudfront.net/assets/application-26302d2a6543346b9b0ed5c9466e5b81.js"
         ]
      },
      "assets":{
         "http://cl.ly/image/0Q3P1I3Z071R/static-showdown-transparent-light.png":{
            "dependent_urls":[
               "http://wynnnetherland.com/",
               "http://wynnnetherland.com/linked/2014020201/a-field-guide-to-static-apps"
            ]
         },
         "http://dfiuq0wxrdccr.cloudfront.net/assets/application-26302d2a6543346b9b0ed5c9466e5b81.js":{
            "dependent_urls":[
               "http://wynnnetherland.com/",
               "http://wynnnetherland.com/talks",
               "http://wynnnetherland.com/linked/2014042901/fifty-years-of-basic-the-programming-language-that-made-computers-personal",
               "http://wynnnetherland.com/journal/thanks-jim"
            ]
         }
      }
   }
}
```

# Running the specs

Run the specs with:

`script/test`

