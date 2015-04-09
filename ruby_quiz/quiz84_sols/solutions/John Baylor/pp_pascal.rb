# pp_pascal.rb
# for details, see http://www.rubyquiz.com/quiz84.html

class Pascal
 def initialize( depth )
   @d = depth
   @p = [[1]]
   1.upto(@d-1) do |row|
     @p[row] = [1]
     1.upto(row-1) do |col|
       @p[row] << (@p[row-1][col-1] + @p[row-1][col])
     end
     @p[row] << 1
   end
 end
 def show
   # the middle entry in the bottom row will have the
   # most digits - use its length as the per-entry span
   span = (@p[-1][(@d / 2).to_i].to_s.length) * 2
   width = @d * span
   rows = []
   @p.each do |p|
     ret = ''
     p.each do |i|
       ret += i.to_s.center(span)
     end
     rows << ret.center(width)
   end
   rows.join("\n")
 end
end

# default to 10 rows
rows = (ARGV[0] || 10).to_i
p = Pascal.new(rows)
puts p.show
