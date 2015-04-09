1.upto(100) do |i|
  buffer = i % 3 == 0 ? "Fizz" : nil
  buffer = buffer.to_s + "Buzz" if i % 5 == 0
  p buffer || i
end
