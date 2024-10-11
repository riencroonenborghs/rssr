# Bootlegger

Bootlegger

## Tech

  - Ruby on Rails 6
  - PostgreSQL
  - Sidekiq

[![Ruby on Rails - Install dependencies, run security checks, linters and tests](https://github.com/riencroonenborghs/rssr/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/riencroonenborghs/rssr/actions/workflows/rubyonrails.yml)

## What can it do?

  - authentication
  - manage feeds:
    - RSS & atom feeds
    - supports tumblr, blogger, medium and reddit URLs
  - refreshes every 30 minutes
  - 2 week data retention
  - filtering
  - bookmarking
  - search
  - saved searches
  - infinite scrolling

## How to run

  - `cp .env.example .env` and edit to your liking
  - edit `db/seeds.rb` to your liking
  - `rails db:create db:migrate db:seed`
  - `overmind start` or `foreman start`

