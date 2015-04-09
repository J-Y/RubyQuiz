f = 3
b = 5

for i in 1..100 do
    if i == f
        if i == b
            puts "fizzbuzz"
            f += 3
            b += 5
        else
            puts "fizz"
            f += 3
        end
    elsif i == b
        puts "buzz"
        b += 5
    else
        puts i
    end
end
