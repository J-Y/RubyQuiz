ARGV[0].to_i.upto(ARGV[1].to_i) do |x|
 puts case [15,5,3].find {|i| x % i == 0}
   when 15 : 'FizzBuzz'
   when 5  : 'Buzz'
   when 3  : 'Fizz'
   when nil: x
 end
end
