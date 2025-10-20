web: bundle exec puma -C ./config/puma.rb
js: yarn build --watch
css: yarn build:css --watch
log: tail -f log/development.log
workers: bundle exec sidekiq -C config/sidekiq.yml
