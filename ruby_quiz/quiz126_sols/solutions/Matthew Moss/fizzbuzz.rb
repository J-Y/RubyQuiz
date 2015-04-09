1.upto(100) do |i|
  puts case i % 15
     when 0 then "FizzBuzz"
     when 5, 10 then "Buzz"
     when 3, 6, 9, 12 then "Fizz"
     else i
  end
end
