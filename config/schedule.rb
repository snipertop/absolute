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
# development start
# set :bundle_command, "/home/dinian/.rbenv/shims/bundle exec"

# set :output, "/home/dinian/absolute/log/cron.log"

# set :environment, :development

# every 1.day, at: '5:10 pm' do
#     runner "ApiHelper.jdy_account_sync"
#     runner "StudentUserHelper.jdy_student_user_sync"
# end

# every 2.minutes do
#     runner "ApiHelper.jdy_account_sync"
# end
# development end

# production start
set :bundle_command, "/home/ruby/.rbenv/shims/bundle exec"

set :output, "/home/ruby/rails7/absolute/log/cron.log"

set :environment, :production

# 简道云-主数据 教师基本信息
every 1.day, at: '9:10 am' do
    runner "ApiHelper.jdy_account_sync"
end
# 简道云-主数据 学生基本信息
every 1.day, at: '7:05 am' do
    runner "StudentUserHelper.jdy_student_user_sync"
end
# 企业微信-主数据 学生通讯录
every 1.day, at: '5:10 pm' do
    runner "WexinUserHelper.wexin_user_sync"
end
# production end

# every 2.minutes do
#     runner "ApiHelper.jdy_account_sync"
# end

# whenever -i
# whenever -w
# crontab -l
# RAILS_ENV=production rails s -p 3002 -d