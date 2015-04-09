def fizzbuzz(value)
  result = "FizzBuzz"
  result.gsub!("Buzz", "") if value % 5 != 0
  result.gsub!("Fizz", "") if value % 3 != 0
  result = value if result.empty?
  result 
end

(1..100).each {|x| puts fizzbuzz(x)}
