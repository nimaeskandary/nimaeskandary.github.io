#!/usr/bin/env bash

git checkout jekyll
git branch -D master
git checkout -b master

bundle exec jekyll build

rm -rf _config.yml \
    index.md \
    Gemfile \
    Gemfile.lock \
    _includes \
    _layouts \
    _posts \
    _sass \
    .sass_cache \
    assets \
    about.md

cp -r _site/ ./

rm -rf _site
