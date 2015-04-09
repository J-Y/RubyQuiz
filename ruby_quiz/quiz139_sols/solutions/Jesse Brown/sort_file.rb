#!/usr/bin/env ruby
#
# Jesse Brown

(puts "Usage: #$0 ip_file" ; exit 1) unless ARGV.length == 1

out = File.open("sorted.ip", "w") or fail "open 'sorted.ip' failed"
ips = []

File.open(ARGV.shift).each do |line|

   # ignore commented and empty lines
   next if line =~ /^\s*$/
   next if line =~ /^#/

   # we are only interested in the range of ips and the country name
   start, stop, w, x, y, z, place = line.strip.split(',')
   ips << "%10s:%10s:%50s" % [start.gsub(/"/,''), stop.gsub(/"/,''),
place.gsub(/"/,'')]

end

# Sorting allows us to do a binary search on the file itself
out.puts ips.sort.join("\n")
out.close
