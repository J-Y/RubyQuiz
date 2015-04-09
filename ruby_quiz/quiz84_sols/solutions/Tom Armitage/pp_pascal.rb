# Pascal's triangle - Rubyquiz # 84

rows = ARGV[0].to_i
@output = []

puts "Pascal's triangle with #{rows} rows"

count = 0

1.upto(rows) do |i|
 if count == 0
   @output[count] = [1]
   count = count.next
 elsif count == 1
   @output[count] = [1, 1]
   count = count.next
 else
   line = []
   line[0] = 1
   1.upto(count - 1) do |index|
     line[index] = (@output[count-1][index-1].to_i +
@output[count-1][index].to_i)
   end
   line[count] = 1
   @output << line
   count = count.next
 end
end

maxrowlength = @output[@output.size - 1].join(" ").length

@output.each do |row|
 string = row.join(" ")
 puts string.center(maxrowlength)
end
