# frozen_string_literal: true

desc "This task is called by the Heroku scheduler add-on"
task :start_availability_check => :environment do
  YokohamaService.new.start_availability_check
end
