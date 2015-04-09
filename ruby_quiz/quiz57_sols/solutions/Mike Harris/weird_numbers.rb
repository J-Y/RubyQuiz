class Integer
 def each_divisor
   for i in 1...self
     yield(i) if self%i == 0
   end
 end

 def weird?
   sum = 0
   each_divisor do |i| sum += i end
   return false if sum <= self
   each_divisor do |i|
     return false if sum-i == self
   end
 end
end

print "Enter Number (Program will print all lesser weird numbers): "
num = gets
for i in 1...num.to_i
 puts i if i.weird?
end
