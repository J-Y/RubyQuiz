# spiral.rb
# RubyQuiz #109
# Bob Showalter

class Integer

 def odd?
   self % 2 == 1
 end

end

class Spiral

 # order must be > 0
 def initialize(order)
   raise ArgumentError, "order must be > 0" unless order.to_i > 0
   @order = order
 end

 # writes the spiral to stdout
 def output
   puts "\n"
   0.upto(@order - 1) do |r|
     row_for(@order, r)
     puts "\n\n"
   end
 end

 private

 # emits row r for spiral of order p
 def row_for(p, r)
   if p <= 1
     cell(0)
   elsif p.odd?
     if r == p - 1
       row(p)
     else
       row_for(p - 1, r)
       col(p, r)
     end
   else
     if r == 0
       row(p)
     else
       col(p, r)
       row_for(p - 1, r - 1)
     end
   end
 end

 # emits the full row (top or bottom) for spiral of order p
 def row(p)
   x = p * (p - 1)
   y = x + p - 1
   x.upto(y) {|i| cell(p.odd? ? x - i + y : i) }
 end

 # emits the single column cell for row r of spiral of order p
 def col(p, r)
   x = p * (p - 1)
   r = p - r - 1 if p.odd?
   cell(x - r)
 end

 # emits a single cell
 def cell(i)
   printf ' %3d ', i
 end

end

n = (ARGV.first || 3).to_i
Spiral.new(n).output
