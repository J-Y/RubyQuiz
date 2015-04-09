#
# Here is my matrix solution.
# It does the Matrix extra credit.
# If there are multiple rectangles that equal max sum, it prints all of them.
#
# Since the quiz did not specify how to input,
# I just hard coded a sample Matrix at the beginning.


require 'matrix'
mat=Matrix[[7,-1,2,3,-4],[-7,8,-22,10,11],[3,15,16,17,-18],[4,22,-23,-24,-25]]
s = []
(0...mat.row_size).each do |a|
 (0...mat.column_size).each do |b|
   (1..mat.row_size).each do |x|
     (1..mat.column_size).each do |y|
     s << mat.minor(a,x,b,y)
     end
   end
 end
end

tot = s.uniq.map {|x| x.to_a}
bg=tot.max{|x,y|x.flatten.inject(0){|a,b|a+b}<=>y.flatten.inject(0){|c,d|c+d}}
sb=tot.select{|r|r.flatten.inject(0){|a,b|a+b}==bg.flatten.inject(0){|c,d|c+d}}
puts "Original Matrix"
(0...mat.row_size).each do |x|
print mat.row(x).to_a.map{|m| m.to_s.rjust(tot.flatten.max.to_s.length+2)},"\n"
end
puts
puts "Solutions"
sb.each do |x|
puts
 x.each {|y| print y.map{|m| m.to_s.rjust(tot.flatten.max.to_s.length+2)},"\n"}
end
