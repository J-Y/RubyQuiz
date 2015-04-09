#!/usr/local/bin/ruby -w

rows     = (ARGV.shift || 10).to_i
triangle = Array.new

rows.times do |row|
  case row
  when 0
    triangle << [1]
  when 1
    triangle << [1, 1]
  else
    triangle << [1]
    (row - 1).times do |i|
      triangle[-1] << triangle[-2][i] + triangle[-2][i + 1]
    end
    triangle[-1] << 1
  end
end

exit if rows.zero?

field_width = triangle[-1].map { |n| n.to_s.size }.max
triangle.map! do |row|
  row.map { |n| n.to_s.center(field_width) }.join(" " * field_width)
end

row_width = triangle[-1].size
triangle.each do |row|
  puts row.center(row_width)
end
