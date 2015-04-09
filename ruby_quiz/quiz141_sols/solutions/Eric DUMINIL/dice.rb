n=8        #Dice number
d=3        #At least d fives
f=50000    #Display step (0: never, 1:always, f:every f lines)

class Fixnum
  def fact
    return 1 if self<2
    self*(self-1).fact
  end

  def cnp(p)
    self.fact/(p.fact*(self-p).fact)
  end
end

@desirable=(d..n).inject(0){|mem,p| mem+n.cnp(p)*5**(n-p)}

N=6**n
(0...N).step(f){|outcome_id|
  outcome=outcome_id.to_s(6).rjust(n,'0').split('').collect{|dice| dice.to_i+1}
  print "\n#{(outcome_id+1).to_s.rjust(n)} : #{outcome.inspect}"
  print " <==" unless outcome.select{|dice| dice==5}.size<d
} unless f==0

puts "\nNumber of desirable outcomes is #{@desirable}"
puts "Number of possible outcomes is #{N}"
puts "Probability is #{@desirable.to_f/N}"
