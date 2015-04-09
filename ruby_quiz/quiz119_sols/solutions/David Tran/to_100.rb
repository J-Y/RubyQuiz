#  http://davidtran.doublegifts.com/blog/?p=11


# Reuse permutations method on my Ruby Quiz (#106) Chess960 solution.
def permutations(elements)
 return [elements] if elements.size <= 1
 result = []
 elements.uniq.each do |p|
   _elements = elements.dup
   _elements.delete_at(elements.index(p))
   permutations(_elements).each do |perm|
     result << (perm << p)
   end
 end
 result
end

def find(digits, operators, target)
 raise "Error: More operators than digits." if (digits.size <= operators.size)
 operators[digits.size - 2] = nil if (operators.size != digits.size - 1)
 found = 0
 stars = "*" * 25
 perm = permutations(operators)
 perm.each do |operator|
   expression = digits.zip(operator).flatten.join
   value = eval(expression)
   if value == target
     found += 1
     puts stars
     puts "#{expression} = #{value}"
     puts stars
   else
     puts "#{expression} = #{value}"
   end
 end
 puts "#{perm.size} possible equations tested."
 puts "#{found} equations satisfied."
end

if ($0 == __FILE__)
 digits    = ARGV[0] || "123456789"
 operators = ARGV[1] || "+--"
 target    = ARGV[2] || "100"

 if (digits =~ /[^1-9]/ || operators =~ /[^-+*\/]/)
   puts "Usage: #$0  digits  operators  target"
   exit
 end

 find(digits.split(//), operators.split(//).map{|e| " #{e} "}, target.to_i)
end
