require 'amb'

A = Amb.new

begin
  a = A.choose(*(0..4))
  b = A.choose(*(0..4))
  c = A.choose(*(0..4))

  A.assert a < b
  A.assert a + b == c

  puts "a=#{a}, b=#{b}, c=#{c}"

  A.failure

rescue Amb::ExhaustedError
  puts "No More Solutions"
end
