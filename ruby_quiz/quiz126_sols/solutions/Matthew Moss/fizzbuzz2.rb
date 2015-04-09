1.upto(100) do |i|
  f, b = (i % 3).zero?, (i % 5).zero?
  puts "#{'Fizz' if f}#{'Buzz' if b}#{i unless (f or b)}"
end
