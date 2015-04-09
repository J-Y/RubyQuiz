#!/usr/bin/env ruby
#
# Jesse Brown

(puts "Usage: #$0 <ip_address>" ; exit 1) if ARGV.length != 1
(puts "Run sort_file.rb first" ; exit 2) unless test(?f, "sorted.ip")

LINE_SZ = 73   # "%10d:%10d:%50s\n"
LINES = File.stat("sorted.ip").size / LINE_SZ

# Binary search on a file
def bin_search(file, target, front, back)

   return "Not Found" if front > back

   mid = (back - front)/2
   file.pos = (front + mid) * LINE_SZ

   start, stop, place = file.read(LINE_SZ).strip.split(':')

   # if within the current range, report...
   return place.lstrip if target >= start.to_i and target <= stop.to_i

   # else recursively search the apropriate half
   if target < start.to_i
      bin_search(file, target, front, back - mid - 1)
   else
      bin_search(file, target, front + mid + 1, back)
   end

end

# Grab and convert the IP. Search
file = File.open("sorted.ip", "r")
a, b, c, d = ARGV.shift.split('.')
target = a.to_i*256**3 + b.to_i*256**2 + c.to_i*256 + d.to_i
puts bin_search(file, target, 0, LINES)
