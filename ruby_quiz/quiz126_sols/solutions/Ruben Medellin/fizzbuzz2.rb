str = (1..100).inject('') do |s, n|
  s + (
    if (n3 = n % 3 == 0) & (n5 = n % 5 == 0)
      "FizzBuzz"
    elsif n3
      "Fizz"
    elsif n5
      "Buzz"
    else
      n.to_s
    end
  ) + "/n"
end

puts str
