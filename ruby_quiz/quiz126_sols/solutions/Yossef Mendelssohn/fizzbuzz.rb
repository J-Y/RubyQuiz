(1..100).each { |x|  str = ''; str += 'Fizz' if (x % 3).zero?; str +=
'Buzz' if (x % 5).zero?; str = x if str.empty?; puts str }
