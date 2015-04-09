#!/usr/bin/env ruby

# The output spec changed, so my script has too.
# It's a bit longer now, oh well.

require 'enumerator'

# Return a Pascal triangle (nested array form) of nrows rows.
# triangle(3) => [[1], [1, 1], [1, 2, 1]]
def triangle(nrows)
  return [[1]] if nrows <= 1
  previous = triangle(nrows-1)
  center = previous[-1].enum_for(:each_cons, 2).map {|a| a[0] + a[1] }
  return previous << ( [1] + center + [1] )
end

# Make an appropriately sized triangle
the_triangle = triangle((ARGV[0] || 13).to_i)

# Figure out how much space to allot for each number
nspaces = the_triangle.flatten.max.to_s.length + 2
nspaces += nspaces % 2  # make sure nspaces is odd, it looks better that way

# Format the lines of the triangle
lines = the_triangle.map do |row|
  row.inject('') do |line, entry|
    line + entry.to_s.ljust(nspaces)
  end
end

# Print out the triangle
lines.each do |line|
  puts line.center(lines[-1].length)
end
