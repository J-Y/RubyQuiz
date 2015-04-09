def say(n)
 "%s%s" % [(t=(n%3==0)) ? 'Fizz' : '', (n%5==0) ? 'Buzz' : (t ? '' : n)]
end

(1..100).each { |n| puts say(n) }
