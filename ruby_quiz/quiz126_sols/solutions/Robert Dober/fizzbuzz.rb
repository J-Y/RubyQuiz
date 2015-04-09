X = [ %w{FizzBuzz} + %w{Fizz} * 4 ]
Y = %w{Buzz}
(1..100).each do |n|
 puts( X[n%3][n%5]) rescue puts( Y[n%5]||n )
end
