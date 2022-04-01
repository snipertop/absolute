# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# development
# set :bundle_command, "/home/dinian/.rbenv/shims/bundle exec"

# set :output, "/home/dinian/absolute/log/cron.log"

# set :environment, :development

# every 1.day, at: '2:30 pm' do
#     runner "ApiHelper.jdy_account_sync"
# end

# every 2.minutes do
#     runner "ApiHelper.jdy_account_sync"
# end
# production
set :bundle_command, "/home/ruby/.rbenv/shims/bundle exec"

set :output, "/home/ruby/rails7/absolute/log/cron.log"

set :environment, :production

# every 1.day, at: '2:30 pm' do
#     runner "ApiHelper.jdy_account_sync"
# end

every 2.minutes do
    runner "ApiHelper.jdy_account_sync"
end

# whenever -i
# whenever -w
# crontab -l