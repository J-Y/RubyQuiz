def replace(n,list=[["FizzBuzz",15],["Buzz",5],["Fizz",3]])
 list.each { |r,m| return r if n % m == 0 }
 return n
end

puts (1..100).map { |e| replace(e) }
