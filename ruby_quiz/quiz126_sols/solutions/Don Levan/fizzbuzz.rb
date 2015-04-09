(1..100).each do |n|

  case
    when n.modulo(5) == 0 && n.modulo(3) == 0
    print 'FizzBuzz', ' '
    when n.modulo(5) == 0
    print 'Buzz', ' '
    when n.modulo(3) == 0
    print 'Fizz', ' '
    else
    print n, ' '
  end

end
