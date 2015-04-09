class RangeMap

 def initialize
   @values = Hash.new
   @ranges = []
 end

 #Insert your range by specifying the lower bound.
 #RangeMap generates the upper value based on what's
 #already in the map.  While not ideal, it makes it
 #a lot easier to keep the set continuous.
 def insert range_first, value
   @values[range_first] = value
   lowers = @values.keys.sort
   uppers = @values.keys.sort
   lowers.pop
   uppers.shift
   @ranges = []
   for i in 0...lowers.size do
     @ranges << (lowers[i]...uppers[i])
   end
 end

 def find n
   if n < @ranges.first.first || n > @ranges.last.last
       raise "Number outside ranges: #{@ranges.first.first}-#{@
ranges.last.last}"
   end
   range_first = binary_search(n, 0, @ranges.size)
   @values[range_first]
 end

protected
 def binary_search n, a, b
   middle = (a + b) / 2
   range = @ranges[middle]
   if n < range.first
     binary_search(n, a, middle)
   elsif n >= range.last
     binary_search(n, middle, b)
   else
     range.first
   end
 end

end

class Integer

 @@rules = RangeMap.new

 [{ :first => 0, :name => "zero" }, { :first => 1, :name => "one" },
 { :first => 2, :name => "two" }, { :first => 3, :name => "three" },
 { :first => 4, :name => "four" }, { :first => 5, :name => "five" },
 { :first => 6, :name => "six" }, { :first => 7, :name => "seven" },
 { :first => 8, :name => "eight" }, { :first => 9, :name => "nine" },
 { :first => 10, :name => "ten" }, { :first => 11, :name => "eleven" },
 { :first => 12, :name => "twelve" }, { :first => 13, :name => "thirteen"
},
 { :first => 14, :name => "fourteen" }, { :first => 15, :name => "fifteen"
},
 { :first => 16, :name => "sixteen" }, { :first => 17, :name => "seventeen"
},
 { :first => 18, :name => "eighteen" },
 { :first => 19, :name => "nineteen" }].each do |single|
   name = single[:name].freeze
   @@rules.insert(single[:first], lambda {|n| name})
 end

 [{ :first => 20, :name => "twenty" },
 { :first => 30, :name => "thirty" },
 { :first => 40, :name => "forty" },
 { :first => 50, :name => "fifty" },
 { :first => 60, :name => "sixty" },
 { :first => 70, :name => "seventy" },
 { :first => 80, :name => "eighty" },
 { :first => 90, :name => "ninety" }].each do |ten|
   divisor = ten[:first]
   name = ten[:name].freeze
   @@rules.insert(divisor, lambda do |n|
     spelt = name.dup
     remainder = n % divisor
     spelt << "-" + execute_rule(remainder) if remainder != 0
     spelt
   end)
 end

 [{ :first => 1E2.to_i, :name => "hundred" },
 { :first => 1E3.to_i, :name => "thousand" },
 { :first => 1E6.to_i, :name => "million" },
 { :first => 1E9.to_i, :name => "billion" },
 { :first => 1E12.to_i, :name => "trillion" },
 { :first => 1E15.to_i, :name => "quadrillion" },
 { :first => 1E18.to_i, :name => "quintillion" },
 { :first => 1E21.to_i, :name => "sextillion" },
 { :first => 1E24.to_i, :name => "septillion" },
 { :first => 1E27.to_i, :name => "octillion" },
 { :first => 1E30.to_i, :name => "nonillion" },
 { :first => 1E33.to_i, :name => "decillion" },
 { :first => 1E36.to_i, :name => "undecillion" },
 { :first => 1E39.to_i, :name => "duodecillion" },
 { :first => 1E42.to_i, :name => "tredecillion" },
 { :first => 1E45.to_i, :name => "quattuordecillion" },
 { :first => 1E48.to_i, :name => "quindecillion" },
 { :first => 1E51.to_i, :name => "sexdecillion" },
 { :first => 1E54.to_i, :name => "septendecillion" },
 { :first => 1E57.to_i, :name => "octodecillion" },
 { :first => 1E60.to_i, :name => "novemdecillion" },
 { :first => 1E63.to_i, :name => "vigintillion" }].each do |big|
   divisor = big[:first]
   name = " " + big[:name].freeze
   @@rules.insert(divisor, lambda do |n|
     spelt = execute_rule(n/divisor) + name
     remainder = n % divisor
     if (remainder > 0)
       if remainder < 100
         spelt << " and "
       else
         spelt << ", "
       end
       spelt << execute_rule(remainder)
     end
     spelt
   end)
 end

 def self.execute_rule n
   @@rules.find(n).call(n)
 end

 def to_english
   self.class.execute_rule(self)
 end
end

puts 123456789.to_english
