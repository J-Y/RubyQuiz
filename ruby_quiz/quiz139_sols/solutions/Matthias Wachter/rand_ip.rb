#!/usr/bin/ruby

r=ARGV[0].to_i

EOL= ARGV[1] ? "\n" : " "

r.times {
  print "#{rand(256)}.#{rand(256)}.#{rand(256)}.#{rand(256)}#{EOL}"
}
