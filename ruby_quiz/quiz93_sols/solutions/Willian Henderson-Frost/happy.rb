# William Henderson-Frost
# Ruby-Quiz 93

# This solution works for base ten numbers.
# I look forward to seeing how others handle the different bases.
# (googolplex ** googolplex) is a happy number =D

class Integer

  def happy?
    n, found = self, []
    loop do
      found << n ; next_n = 0
      n.to_s.scan(/./) { |i| next_n += i.to_i**2 } ; n = next_n
      return found if n == 1
      return false if found.index(n)
    end
  end

  def Integer.happiest(limit)
    num = 1
    (1..limit).each { |n| num = n if n.happy? and n.happy?.size > num.happy?.size }
    num
  end

end

#puts Integer.happiest(1000000)
#puts (('9' * 975) + '421111').to_i.happy?

puts 2.happy?                             #=>  false
puts 78999.happy?.join(', ')       #=>  78999, 356, 70, 49, 97, 130, 10
