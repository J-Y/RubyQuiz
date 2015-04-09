# Marcel Ward   <wardies ^a-t^ gmaildotcom>
# Saturday, 2006-04-07
# Solution for Ruby Quiz #119  <http://www.rubyquiz.com/>
#
################################################
# getting-to-x.rb

class GettingToX
 def initialize(no_of_plusses, no_of_minusses, target_number)
   @plusses = no_of_plusses
   @minusses = no_of_minusses
   @target = target_number
 end

 # Recursively called whilst preparing the calculation string,
 # which is passed in calc_prefix
 def prepare_sum(rem_plus, rem_minus, cur_digit, calc_prefix)
   cur_digit += 1

   # Do we have any remaining plus signs to use up?
   if rem_plus > 0
     prepare_sum(rem_plus - 1, rem_minus, cur_digit,
       calc_prefix + " + %c" % (?0 + cur_digit))
   end

   # Do we have any remaining minus signs to use up?
   if rem_minus > 0
     prepare_sum(rem_plus, rem_minus - 1, cur_digit,
       "#{calc_prefix} - %c" % (?0 + cur_digit))
   end

   digits_remaining = 10 - cur_digit
   if rem_plus + rem_minus < digits_remaining
     # We can use a digit here and we'll still have room to
     # fit in all our operators later
     prepare_sum(rem_plus, rem_minus, cur_digit,
       "#{calc_prefix}%c" % (?0 + cur_digit))
   elsif rem_plus + rem_minus == 0
     # We have run out of operators; use up all the digits
     cur_digit.upto(9) {|n| calc_prefix += "%c" % (?0 + n)}
     calc(calc_prefix)
   end
 end

 # Print out the sum (with highlights if the target value was hit).
 def calc(whole_sum)
   result = eval(whole_sum)
   target_hit = (result == @target)
   puts '*' * 30 if target_hit
   puts whole_sum + ' = ' + result.to_s
   puts '*' * 30 if target_hit
   @total_evals += 1
   @target_matches += 1 if target_hit
 end

 def do_sums
   @total_evals = 0
   @target_matches = 0
   # We must always start with a string containing the first digit,
   # i.e. "1" because after this comes either the next digit or +/-
   prepare_sum(@plusses, @minusses, 1, '1')
   puts "#{@total_evals} possible equations tested"
   @target_matches
 end
end

# Show results for 1 plus, 2 minusses, target of 100
x = GettingToX.new(1, 2, 100)
matches = x.do_sums

# How did we do?
puts "** #{matches} equation(s) matched target value **"
