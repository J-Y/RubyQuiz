#!/usr/bin/ruby
ARGV.each { |ip|
  f = ip.split(/\./).join "/"
  puts File.open(f).readlines[0] rescue puts "Unknown"
}
