(1..100).each do |i|
 s = ''
 s << "Fizz" if (i % 3 == 0)
 s << "Buzz" if (i % 5 == 0)
 puts(s == '' ? i : s)
end
