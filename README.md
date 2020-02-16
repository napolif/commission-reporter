# README

Commission Reporter is a Rails app for calculating Napoli Foods commission payments.

## Requirements

* Ruby 2.6.2
* Bundler 2.1.4
* PostgreSQL

## Installation

### Set up OS

* make an instance of latest Ubuntu Server
* `sudo ufw allow 3000/tcp` (for development server)
* `sudo apt-get install wkhtmltopdf`

### Install PostgreSQL

* `sudo apt-get install postgresql`
* `sudo apt-get install libpq-dev`
* `sudo su`
* `su postgres`
* `createuser -s --username=postgres <username>` (and exit)

### Install Ruby (using rbenv)

* `mkdir` & `chown` /app
* `sudo apt-get install rbenv`
* install ruby-build as an rbenv plugin: https://github.com/rbenv/ruby-build#installation
* `rbenv init` & add rbenv to shell rc file as it instructs

### Install Yarn

* `curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -`
* `echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list`
* `sudo apt-get update`
* `sudo apt-get install yarn`

### Clone app & install ruby/js dependencies

* `git clone https://github.com/johncip/napoli-commission-app` (will need credentials)
* `gem install bundler:2.1.4`
* `bundle install`
* `yarn install --check-files`
* `bundle exec rake db:setup`
* ensure that the server's hostname is added to `config.hosts` in e.g. `config/environments/development.rb`

### Running

* `cd /app/napoli-commission-app`
* `bundle exec rails server`

## Updating

* `cd /app/napoli-commission-app`
* `git pull`
* `bundle install`
* `yarn`
