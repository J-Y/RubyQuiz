class Operators
 OPS = ['','+','-']
 attr_reader :operators

 def initialize(size)
  @operators = [0] * size
 end

 def next_operator(n = 0) 
  if @operators[n] < (OPS.size - 1)
   @operators[n] += 1
  else
   @operators[n] = 0
   next_operator(n + 1)
  end
 end
end

class Equation
 NUM = [1,2,3,4,5,6,7,8,9]
 attr_reader :string 

 def initialize(operators)
  @string = NUM.zip(operators.operators.map { |o| Operators::OPS[o]}.flatten.compact).join('')
 end

 def answer
  eval(@string)
 end
end

tested = 0
found = 0
match = 100

ops = Operators.new(Equation::NUM.size-1)
(Operators::OPS.size**(Equation::NUM.size-1)-1).times do
 eq = Equation.new(ops)
 answer = eq.answer

 puts "************************" if answer == match 
 puts "#{eq.string} = #{answer}"
 puts "************************" if answer == match

 ops.next_operator
 tested += 1
 found += 1 if answer == match
end

puts "#{tested} equations tested, #{found} evaluated to #{match}" 
