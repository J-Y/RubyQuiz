# fizz.rb
1.upto(ARGV[0].to_i) do |n|
  if n % 15 == 0
    print "FizzBuzz "
  elsif n % 5 == 0
    print "Buzz "
  elsif n % 3 == 0
    print "Fizz "
  else print "#{n} "
  end
end
puts
