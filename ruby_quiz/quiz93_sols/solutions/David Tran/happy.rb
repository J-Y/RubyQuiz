class Integer
 def digits(base = 10)
   return [self] if self < base
   self.divmod(base).inject { |div, mod| div.digits(base) << mod }
 end

 def happy?(base = 10)
   _happy?([], base)
 end

 protected

 def _happy?(happy_list, base)
   return false if happy_list.include?(self)
   happy_list << self
   return happy_list if self == 1
   self.digits(base).inject(0) { |n, d| n + d*d }._happy?(happy_list, base)
 end
end


# Find happiest between 1 and 1_000_000
#
# 1_000_000 is not the happiest. ( [1000000, 1] )
# So, all numbers <= 999_999 after first iteration
# will <= (9**2) * 6  ( = 486 )
#
# Also the rule to determine happy for number
# 123 is the same as 231, 321, 12300, 10230 ... etc
# So, for all 2 digits numbers, we only need to check 55 numbers,
# for all 3 digits numbers, we only need to check 220 numbers ... etc
#
# Here will not use this optimization, because the happiest does not
# so slow ( at least on my PC ) to find it ...

if __FILE__ == $0

 # find all happy numbers ( max happy rank ) between 1 .. (9**2)*6
 rate = 1
 list = [1]
 max = (9**2) * 6
 (1..max).each do |n|
   happy = n.happy?
   next unless happy
   if happy.size == rate
     list << n
   elsif happy.size > rate
     rate = happy.size
     list = [n]
   end
 end

 happiest = ((max+1)..1_000_000).each do |n|
   break n if list.include?(n.digits.inject(0) { |sum, d| sum + d*d })
 end

 puts "the happiest number between 1 and 1,000,000 is #{happiest}"
 p happiest.happy?
end
