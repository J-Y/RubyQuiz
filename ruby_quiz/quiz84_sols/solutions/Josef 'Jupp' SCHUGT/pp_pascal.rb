exit 1 if ARGV.length != 1 || ARGV[0] =~ /[^\d]/
rows = Array.new
current = [1]
rows.push current.dup
(ARGV[0].to_i + 1).times do |row|
  (current.length - 2).times { |i| current[i] += current[i + 1] }
  current[0...0], current[-1] = 1, 1
  rows.push current.dup
end
fieldsize = rows.last.map { |n| n.to_s.length }.max
rows.each_with_index do |row, n|
  print ' ' * (fieldsize + 1) * (rows.length - n - 1)
  puts row.map { |elem| elem.to_s.rjust(fieldsize) + ' ' * (fieldsize + 2) }.join
end
