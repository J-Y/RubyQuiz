numberOfRows = ARGV[0].to_i



# Handles the case where the number of rows asked for is 1

numberOfRows.eql?(1) ? (puts("1");exit) : nil



# Genereate Pascal's Triangle

rows = [[1],[1,1]]

2.upto(numberOfRows-1) do |currentRowIndex|

 rows[currentRowIndex] = [1]

 1.upto(currentRowIndex-1) do |elementIndex|

   rows[currentRowIndex] << rows[currentRowIndex-1][elementIndex-1] + rows[currentRowIndex-1][elementIndex]

 end

 rows[currentRowIndex] << 1

end



# Get  the length in characters  of the largest element

maxElementLength = rows[numberOfRows - 1][numberOfRows/2].to_s.length



# Format and ouput the triangle

puts(rows.map do |row|

 ' '*maxElementLength*(numberOfRows - row.length) +

 row.map do |element|

   element.to_s +

   ' '*(maxElementLength-element.to_s.length) +

   ' '*maxElementLength

   end.join

end.join("\n"))
