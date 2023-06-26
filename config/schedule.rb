# https://github.com/javan/whenever
# Use this file to easily define all of your cron jobs.
# It's helpful, but not entirely necessary to understand cron before proceeding.

set :output, "/home/deploy/commission-app/log/cron.log"
set :environment, "production"

job_type :rake, 'export PATH="$HOME/.rbenv/bin:$PATH"; eval "$(rbenv init -)"; cd :path && :environment_variable=:environment bundle exec rake :task --silent :output'

# NOTE: local server time (which cron uses) is eastern

every 1.day, at: "12:30 am" do
  rake "retalix:import"
end
