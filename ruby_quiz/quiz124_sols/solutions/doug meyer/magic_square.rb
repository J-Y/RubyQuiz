#!/usr/bin/env ruby
# Douglas Meyer

class Array
  def sum
    inject(0){|a,v|a+=v}
  end
end

rows = ARGV[0].to_i
puts "Sorry, this program only works for odd row values!" if rows % 2 == 0

row_sum = (1..rows**2).to_a.sum/rows
puts "Row Sum: #{row_sum}"
decimals = (Math::log(row_sum)/Math::log(10)).to_i

square = Array.new(rows){Array.new(rows, 0)}

row = (rand*rows+1).to_i
col = (rand*rows+1).to_i

#Computer square
(1..rows**2).each do |count|
  row = (row - 1) % rows
  col = (col - 1) % rows
  square[row][col] = count
  unless square[(row-1)%rows][(col-1)%rows] == 0
    col -= 2
    row -= 1
  end
end

#Display and check sums
string = "% #{decimals+2}d"*rows+" = % #{decimals+1}d"
square.each{ |row|
  output = row
  output << row.sum
  puts string % output
}
puts (" "*(decimals)+"= ")*rows
string = "% #{decimals+2}d"*rows
puts string % square.inject(Array.new(rows,0)){|sum,row|
  sum = sum.zip(row).map{|a|a.sum}
}