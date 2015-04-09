#!/usr/local/bin/ruby -w

require "robot_rules"
require "open-uri"

rules      = RobotRules.new("RubyQuizBrowser 1.0")
robots_url = "http://pragmaticprogrammer.com/robots.txt"

open(robots_url) do |url|
  data = url.read

  puts "/robots.txt:"
  puts data
  puts

  rules.parse(robots_url, data)
end

puts "URL tests:"
%w{ http://pragmaticprogrammer.com/images/dave.jpg
    http://pragmaticprogrammer.com/imagination }.each do |test|
  puts "rules.allowed?( #{test.inspect} )"
  puts rules.allowed?(test)
end
