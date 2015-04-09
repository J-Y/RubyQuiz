(1..100).each do |i|
  result = ''
  result += 'Fizz' if i % 3 == 0
  result += 'Buzz' if i % 5 == 0
  result = i if result.empty?
  puts result
end
