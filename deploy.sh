#!/bin/bash

set -e

cd /home/deploy/commission-app
git reset --hard
git checkout master
git pull

sudo systemctl stop puma.service

export RAILS_ENV=production
bundle config set without "development test"

bundle install
yarn install

bundle exec rake db:migrate
bundle exec rake assets:precompile

sudo systemctl start puma.service
sudo service nginx reload
