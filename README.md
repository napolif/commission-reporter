# Commission Reporter

Commission Reporter is a Rails app for calculating commission payments.

## Requirements

* Ruby 2.6.2
* Bundler 2.1.4
* PostgreSQL

## Installation

Much of this is adapted from https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-14-04.
Some of it might be out of order.

### Set up OS

* make an instance of latest Ubuntu Server
* `sudo ufw allow 3000/tcp`
* `sudo apt-get update`
* `sudo apt-get install wkhtmltopdf`
* `sudo adduser deploy`
* `sudo usermod -aG sudo deploy`
* (do everything as "deploy" from here on)

### Install & configure postgresql

* `sudo apt-get install postgresql postgresql-contrib libpq-dev`
* `sudo -u postgres createuser -s napoli`
* `sudo -u postgres psql`, then in psql: `\password napoli` (and create a p/w)
* add `local all napoli md5` to e.g. `/etc/postgresql/11/main/pg_hba.conf`
* `sudo service postgresql restart`

### Install rbenv & ruby

* `sudo apt-get install rbenv`
* `git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build`
* `git clone https://github.com/rbenv/rbenv-vars.git $(rbenv root)/plugins/rbenv-vars`
* `rbenv init` & add rbenv to shell rc file as it instructs
* `rbenv install 2.6.2`

### Install yarn

* `curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -`
* `echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list`
* `sudo apt-get update && sudo apt-get install yarn`

### Clone app & install ruby/js dependencies

* `cd /home/deploy`
* `git clone https://github.com/johncip/napoli-commission-app commission-app`
  * requires github authentication
  * TODO: set up napoli github acct
* `cd napoli-commission-app`
* `gem install bundler:2.1.4`
* `bundle install`
* `yarn install --check-files`

### Set up environment vars

* `cd /home/deploy/commission-app`
* `rake secret` (copy the secret)
* `vim .rbenv-vars` and enter:

```ruby
SECRET_KEY_BASE=$paste_the_secret
COMMISSION_APP_DATABASE_PASSWORD=$the_db_password
```

### Set up Puma service
* see https://github.com/puma/puma/blob/master/docs/systemd.md
* use the first one, set `User=deploy`
* add `Environment=RAILS_ENV=production`
* use "rails start" variant
* configure puma.conf a la https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-14-04

### Configure nginx
* see https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-puma-and-nginx-on-ubuntu-14-04

### Initial setup

* add the server's hostname to `config.hosts` in `config/environments/production.rb`
  * this part must be committed to the codebase
  * TODO: add the hostname dynamically
* `bundle exec rake db:setup`

## Deploying / Update / Run

* run `/home/deploy/commission-app/deploy.sh`

(Summary: stop puma, set `RAILS_ENV` to production, bundle & yarn install, migrate, compile assets, restart puma, reload nginx)
