1.upto(100) do |n|
    output = Array.new
    output << "Fizz" if (n % 3 == 0)
    output << "Buzz" if (n % 5 == 0)
    output << n if output.empty?
    puts output.to_s
end
