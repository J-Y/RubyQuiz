require "rational"

# I derived the nCk formula myself, didn't wanna cheat.
class Fixnum
 def choose(k); (1..k-1).inject(1){ |s,e| s *= Rational(self,e) - 1 }; end
end

# not to disappoint JEG2, I decided to maintain my record of
# "never completing a ruby quiz", so take the formatting with a grain of salt.
1.upto(ARGV[0].to_i) { |n| puts((1..n).map {|k| n.choose k }.join("|")) }
