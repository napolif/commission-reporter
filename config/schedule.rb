# https://github.com/javan/whenever
# Use this file to easily define all of your cron jobs.
# It's helpful, but not entirely necessary to understand cron before proceeding.

set :output, "/commission_reporter/log/cron.log"
set :environment, "production"

# NOTE: local server time (which cron uses) is eastern

every 1.day, at: "12:30 am" do
  rake "retalix:import"
end
