class Integer
  def === num
    num % self == 0
  end
end

100.times do |x|
  case x
    when 15: puts "FizzBuzz"
    when 3: puts "Fizz"
    when 5: puts "Buzz"
    else puts x
  end
end
