class Pascal
 attr_reader :triangle

 def initialize(rows)
   @triangle=[]
   generate(rows)
 end

 def [](row, n)
   if row>0 and row<=@triangle.length and n>0 and n<=@triangle[row-1].length
     @triangle[row-1][n-1]
   else
     nil
   end
 end

 def generate(rows)
   return nil if rows<@triangle.length
   rows.times do |s|
     row=[1]
     1.upto(s-1) do |n|
       row[n]=@triangle[s-1][n-1]+@triangle[s-1][n]
     end
     row[s]=1
     @triangle << row
   end
 end

 def to_s
   spacing=@triangle.last.max.to_s.length
   total_length=(spacing+1)*@triangle.last.length
   @triangle.map do |row|
     row.map do |number|
       number.to_s.center(spacing)
     end.join(" ").center(total_length)
   end.join("\n")
 end

end

puts Pascal.new(ARGV[0].to_i)
