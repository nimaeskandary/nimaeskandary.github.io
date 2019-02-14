---
layout: post
title:  "Setting Up a Blog with Github Pages, Route 53, and CloudFront"
date:   2018-02-11
---

## Tools

* AWS Route 53 (DNS management)
* AWS CloudFront (CDN)
* AWS Certificate Manager (SSL certificate provisioning)
* Github Pages (Static site hosting)
* Jekyll (Static site generator)

## $$

Cost-wise this blog is free to maintain. Registering your custom domain will cost you around $12 annually, and then Route 53 and CloudFront will likely fall in the free tier depending on your traffic. Github Pages is free.

## Hosting a site on Github Pages

Github pages allows you to host websites through static files (you'll need an index.html at least in the root of the repo), or a Jekyll template which Github Pages will auto-build.

1. Make a new repository on Github named `your-account.github.io`, this part is important because it will be your user lever repository, and will be accessible at `your-account.github.io`
1. In the settings of your repo, turn on Github Pages. You don't need to tell it you're using a custom domain here, things will work fine the way it defaults
1. You can either pick a theme right from the suggestions it gives you or try to figure that part on your own. I use the default Jekyll theme `minima`

## Registering your domain

While Github hosts my static site for free at `nimaeskandary.github.io` already, I wanted to buy `nimaeskandary.com` before another Nima Eskandary got any ideas.

1. Log into the [AWS management console](https://aws.amazon.com/console)
1. Search for the service `Route 53`
1. On the left sidebar, under Domains, go to `Registered Domains`
1. Register the domain you want, it took about 10 minutes for my registration to go through. The exact domain I registered was `nimaeskandary.com`

## Provisioning your SSL cert

It is becoming more and more commonplace to block non HTTPS traffic.

1. In the [AWS management console](https://aws.amazon.com/console), set your top right data center to `US EAST (N. Virginia)`. This is important because CloudFront only uses certs stored there, and AWS will store your cert in the data center you are connected to.
1. Search for the service `Certificate Manager`
1. You'll want to add two domain names, `base-domain.com`, in my case this was `nimaeskandary.com`, and `*.base-domain.com`, the wild card is so you can use the cert for any records in your zone, e.g. `www.base-domain.com`, `blog.base-domain.com`
1. When asked, verify that you own the domain through the DNS option, it is very easy and all it will have you do is make a CNAME record in Route 53

## Setting up CloudFront

While you could make a CNAME record that routes `www.you-domain.com` to `your-account.github.io` and be done with it, using CloudFront offers a few advantages:

* It will allow `base-domain.com`, to also point to the right place, because your root zone cannot be a CNAME, but AWS lets you have it point to a CloudFront distribution through a special `alias` record

* It will allow you to also serve your SSL cert, without it people couldn't use HTTPS on your custom domain

1. In the [AWS management console](https://aws.amazon.com/console), search for CloudFront
1. Set up a new "Web" distribution
1. For the `origin domain name`, put the Github pages domain, in my case it was `nimaeskandary.github.io`
1. For `origin path` don't put anything
1. For `viewer protocol policy` I personally `redirect HTTP to HTTPS`
1. For `allowed HTTP methods` do `GET, HEAD, OPTIONS`
1. I change the `default TTL` to 0 because I want people to see my updates right away
1. In `price class` I only use US, Canada, and Europe, really any option is fine
1. For `alternate domain names (CNAMEs)` you'll want any address you think you'll use. I put down `nimaeskandary.com`, `www.nimaeskandary.com`, and `blog.nimaeskandary.com`
1. Choose the Custom SSL cert we made earlier
1. And that's it, it should take about 15 minutes for it to spin up once you click the finish button

## Creating your DNS records

1. In the [AWS management console](https://aws.amazon.com/console), search for Route 53
1. Create an alias record, with no added record name, this will just make the record named `your-domain.com`
1. Have the alias record point to your CloudFront domain name, this can be found in the CloudFront management page for the distribution you just made, and will be something like `dn542fesffj83.cloudfront.net`
1. Optionally, you can also create a CNAME record named `www.`, that points to `your-domain.com`, that way both `www.your-domain.com` and `your-domain.com` work. I also added a `blog.` record as well

---

All done, hope this was helpful. If this gets outdated feel free to shoot me an email
