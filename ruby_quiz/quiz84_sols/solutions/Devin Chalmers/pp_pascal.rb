#!/usr/local/bin/ruby

def pascal_cell(row, col)
 return 1 if col == 0 or col == row
 return pascal_cell(row - 1, col) + pascal_cell(row - 1, col - 1)
end

def pascal_array(depth)
 Array.new(depth) {|i| Array.new(i + 1){|j| pascal_cell(i, j)}}
end

class Array
 def to_centered_spaced_string
   cell_width = self.flatten.collect{|val| val.to_s.size}.max + 2
   row_width  = self.collect{|row| row.size}.max * cell_width
   rows = Array.new(self.size) do |i|
     self[i].collect{|item|item.to_s.center(cell_width)}.join.center(row_width)
   end
   return rows.join("\n")
 end
end

puts pascal_array(ARGV[0].to_i).to_centered_spaced_string
