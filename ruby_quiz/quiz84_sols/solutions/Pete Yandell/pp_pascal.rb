require 'enumerator'

# Generate the triangle.
n = ARGV[0].to_i
rows = (2..n).inject([[1]]) do |rows, i|
  rows << ([0]+rows[-1]+[0]).enum_cons(2).map{|a,b| a+b }
end

# Work out the length in digits of the longest number.
m = rows[-1][n/2].to_s.length
# Print each row with appropriate spacing.
rows.each do |row|
  print ' '*m*(n-row.length)
  print row.collect {|i| sprintf("%#{m}d", i) }.join(' '*m)
  print "\n"
end
