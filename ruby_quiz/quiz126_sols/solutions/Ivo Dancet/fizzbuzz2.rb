#### The first one, 4 mins, but not something I would leave on a page

100.times do |i|
  j = i + 1
  if j%15 == 0
    puts "fizzbuzz"
    next
  end
  if j%3 == 0
    puts "fizz"
    next
  end
  if j%5 == 0
    puts "buzz"
    next
  end
  puts j
end

# hmmm, that wasn't so good :-)
