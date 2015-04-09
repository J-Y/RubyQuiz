#!/usr/bin/ruby -w

#
# Solution to ruby quiz #128
# http://www.rubyquiz.com/quiz128.html
# by Holger
#
# Usage:
#   verbal_arithmetic.rb <equation>
#
# Examples:
#   verbal_arithmetic.rb 'send+more=money'
#   verbal_arithmetic.rb 'a+b==c && a+c==d-b && a*c==d'
#



#*********************************************************************
#  Permutator which gives all combinations of <m> elements out of
#    array <n>
#
#  usage:
#    perms(m, n) { |x| ... }
#
#*********************************************************************

def perms(m, n)
 p = [nil] * m
 t = [-1] * m
 k = 0
 while k >= 0
   if k==m
     yield p
     k = k-1
   end
   n[t[k]] = p[k] if t[k]>=0
   while(t[k]<n.length())
     t[k] = t[k]+1
     if n[t[k]]
       p[k] = n[t[k]]
       n[t[k]] = nil
       k = k+1
       t[k] = -1
       break
     end
   end
   k = k-1 if t[k]==n.length()
 end
end


# Read from command line and make valid ruby expression (= -> == if not already present)
puzzle = ARGV[0].gsub(/=+/,"==")

# Extract all letters and all first letters
digits = puzzle.gsub(/\W/,"").split(//).uniq
starts = puzzle.gsub(/(\w)\w*|\W/,"\\1").split(//).uniq

if digits.length()>= 10
 puts "oops, too much letters"
else
 # String containing all digits
 digitss = digits.join

 # Build "first digit must not be zero" condition
 cond0 = starts.join("*") + "!=0"

 # And now perform an exhaustive search
 puts "solving #{cond0} && #{puzzle}"

 perms(digits.length(), (0...10).to_a) { |v|
   p0 = cond0.tr(digitss, v.join)
   p1 = puzzle.tr(digitss, v.join)
   if eval(p0) && eval(p1)   # Hint: first evaluate p0 as p1 may not be a valid expression
     puts '-- Solution ---'
     [digits, v].transpose.each do |x,y| puts "#{x}: #{y}" end
   end
 }
end
