# RSS Reader

Simple RSS reader. Supports both desktop and mobile browsers.

## Tech

  - Ruby on Rails 7.2
  - SQLite
  - Sidekiq

[![Ruby on Rails - Install dependencies, run security checks, linters and tests](https://github.com/riencroonenborghs/rssr/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/riencroonenborghs/rssr/actions/workflows/rubyonrails.yml)

## What can it do?

  - User authentication
  - Manage feeds
  - Refreshes every 30 minutes
  - 2 week data retention
  - Bookmarks
  - Filtering with [FTS5](https://sqlite.org/fts5.html)

## How to run

  - `cp .env.example .env` and edit to your liking
  - edit `db/seeds.rb` to your liking
  - `EMAIL=... PASSWORD=... ./bin/rails db:create db:migrate db:seed`
  - `yarn install`
  - `./bin/dev`

