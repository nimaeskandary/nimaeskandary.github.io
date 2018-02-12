---
layout: post
title:  "Setting Up a Blog with Github Pages, Route 53, and CloudFront"
date:   2018-02-11
---

## Tools

* AWS Route 53 (DNS management)
* AWS CloudFront (CDN)
* AWS Certificate Manager (TLS certificate provisioning)
* Github Pages (Static site hosting)
* Jekyll (Static site generator)

## $$

Cost-wise this blog is relatively cheap to maintain. Registering your custom domain will cost you around $12 annually, and then Route 53 and CloudFront will cost pennies each month. Cloudfare would be free for their DNS management and CDN, and both Cloudfare and Amazon offer protections from things like DDoS attacks, but I went with Amazon because I already use AWS at work and am comfortable with them

## Hosting a site on Github Pages

This part is better explained with a Google search, but the basics are you serve static sites from your Github repositories, from either the static files themselves (you'll need an index.html at least in the root of the repo), or a Jekyll template.

1) Make a new repository on Github named `your-account.github.io`, this part is important because if you make a user lever repository, it is accessible at `your-account.github.io`, but any other repository will be hosted at `your-account.github.io/repo-name`, and this screws up the custom routing

2) In the settings of your repo, turn on Github Pages. You don't need to tell it you're using a custom domain here, things will work fine the way it defaults

3) You can either pick a theme right from the suggestions it gives you or try to figure that part on your own. I use the default Jekyll theme `minima`

## Registering your domain

While Github hosts my static site for free at `nimaeskandary.github.io` already, I wanted to buy `nimaeskandary.com` because I figured I'd want to snag it before someone else did one day. It also doesn't cost much so I think it's a good investment

1) Log into the [AWS management console](console.aws.amazon.com)

2) Search for the service `Route 53`

3) On the left sidebar, under Domains, go to `Registered Domains`

4) The rest is pretty self explanatory, it took about 10 minutes for my domain registration to go through. The exact domain I registered was `nimaeskandary.com`

## Provisioning your TLS cert

TLS certs, or SSL certs for the older encryption protocol, are used to encrypt HTTP traffic, and are what give the "S" in HTTPS. Though no one will be sending passwords or credit card numbers on your site, the certs are free and it is becoming more and more commonplace to block HTTP traffic unless it is encrypted

1) In the [AWS management console](console.aws.amazon.com), set your top right data center to `US EAST (N. Virginia)`. This is important because CloudFront only uses certs stored there

2) Search for the service `Certificate Manager`

3) You'll want to add two domain names, `base-domain.com`, in my case this was `nimaeskandary.com`, and `*.base-domain.com`, the wild card is so you can use the cert for any records in your zone, e.g. `www.base-domain.com`, `blog.base-domain.com`

4) Verify that you own the domain through the DNS option, it is very easy and all it will have you do is make a CNAME record in Route 53

## Setting up CloudFront

While you could just create a CNAME record like `www.base-domain.com IN CNAME account.github.io` and have that address resolve to your Github pages website, using CloudFront offers a few advantages

* It will allow `base-domain.com`, to also point to the right place, because your root zone cannot be a CNAME, but AWS lets you have it point to a CloudFront distribution through a special `alias` record

* It will allow you to also serve your TLS cert, without is people couldn't use HTTPS on your custom domain

* It provides protections from DDoS attacks

1) In the [AWS management console](console.aws.amazon.com), search for CloudFront

2) Set up a new "Web" distribution

3) For the `origin domain name`, put the Github pages domain, in my case it was `nimaeskandary.github.io`

3) For `origin path` don't put anything

4) For `viewer protocol policy` I personally `redirect HTTP to HTTPS`

5) For `allowed HTTP methods` do `GET, HEAD, OPTIONS`

6) I change the `default TTL` to 0 because I want people to see my updates right away

7) In `price class` I only use US, Canada, and Europe because they are technically the cheapest, but to be honest you wouldn't notice the extra pennies if you chose the best performance option

8) For `alternate domain names (CNAMEs)` you'll want any address you think you'll use. I put down `nimaeskandary.com`, `www.nimaeskandary.com`, and `blog.nimaeskandary.com`

9) Choose the Custom SSL cert we made

10) And that's it, it should take about 15 minutes for it to spin up once you click the finish button

## Creating your DNS records

1) In the [AWS management console](console.aws.amazon.com), search for Route 53

2) Create an alias record, with no added record name, this will just make the record named `your-domain.com`

3) Have the alias record point to your CloudFront domain name, this can be found in the CloudFront management page for the distribution you just made, and will be something like `dn542fesffj83.cloudfront.net`

4) Optionally, you can also create a CNAME record named `www.`, that goes to `your-domain.com`, that way both `www.your-domain.com` and `your-domain.com` work. I also added a `blog.` record as well

---

Congrats, you have a blog with a custom domain name
