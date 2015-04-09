#!/usr/bin/ruby
# Ruby happy number quiz solution.  September 2006
# Hans Fugal

class Happy
  def initialize
    @happy_numbers = { 1 => 0 }
  end

  def happy(n)
    return true if n == 1

    x = n
    rank = 0
    loop do
      sum = 0
      while x > 0
        x, r = x.divmod(10)
        sum += r**2
      end

      rank += 1

      if [0, 1, 4, 16, 20, 37, 42, 58, 89, 145].include?(sum)
        if sum == 1
          @happy_numbers[n] = rank
          return true
        else
          return false
        end
      end

      x = sum
    end
  end

  def rank(x)
    raise ArgumentError, "#{x} is unhappy." unless happy(x)
    return @happy_numbers[x]
  end
end

haphap = Happy.new
ARGF.each_line do |l|
  l.scan(/\d+/) do |token|
    x = token.to_i
    if haphap.happy(x)
      puts "#{x} is happy with rank #{haphap.rank(x)}"
    end
  end
end
