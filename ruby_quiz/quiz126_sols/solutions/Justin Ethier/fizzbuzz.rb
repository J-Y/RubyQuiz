for i in 1...101 # was 100 before checking this
 out = ''
 out = out + 'Fizz' if (i % 3) == 0
 out = out + 'Buzz' if (i % 5) == 0
 out = i.to_s if (out.size) == 0

 print out + "\n" # Original did not have a newline
end
