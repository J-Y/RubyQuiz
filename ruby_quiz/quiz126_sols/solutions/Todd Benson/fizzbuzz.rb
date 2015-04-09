arr = (1..100).map do |i|
 i = (("FizzBuzz" if i%15==0) or ("Fizz" if i%3==0) or ("Buzz" if i%5==0) or i)
end
puts arr
