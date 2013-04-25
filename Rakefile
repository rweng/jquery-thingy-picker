require File.expand_path('../app', __FILE__)
Application.load_tasks

task :serve do
  # shamelessly stolen from: https://github.com/mojombo/jekyll/blob/master/Rakefile
  Thread.new do
    require 'launchy'
    sleep 1
    puts "Opening in browser ..."
    Launchy.open("http://jquery-thingy-picker.herokuapp.com:9292")
  end

  require "rack"
  port = ENV['PORT'] || 9292
  Rack::Server.new(config: File.expand_path("../config.ru", __FILE__), Port: port).start
end