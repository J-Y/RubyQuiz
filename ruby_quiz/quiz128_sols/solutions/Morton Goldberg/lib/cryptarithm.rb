#  lib/cryptarithm.rb
#  Quiz 128
#
#  Created by Morton Goldberg on 2007-06-18.

DIGITS = (0..9).to_a

class Cryptarithm
   @@equation = ""
   @@max_rank = -1
   def self.equation(str=nil)
      if str
         @@equation = str.upcase
         lhs, rhs = @@equation.gsub(/[A-Z]/, "9").split("=")
         @@max_rank = [eval(lhs), eval(rhs)].max
      else
         @@equation
      end
   end
   attr_accessor :ranking, :solution
   def initialize
      @solution = @@equation.delete("+-=").split("").uniq
      @solution = @solution.zip((DIGITS.sort_by {rand})[0, @solution.size])
      rank
   end
   def mutate(where=rand(@solution.size))
      raise RangeError unless (0...@solution.size).include?(where)
      digits = @solution.collect { |pair| pair[1] }
      digits = DIGITS - digits
      return if digits.empty?
      @solution[where][1] = digits[rand(digits.size)]
   end
   def swap
      m = rand(@solution.size)
      n = m
      while n == m
         n = rand(@solution.size)
      end
      @solution[m][1], @solution[n][1] = @solution[n][1], @solution[m][1]
   end
   def rank
      sum = @@equation.dup
      solution.each { |chr, num| sum.gsub!(chr, num.to_s) }
      lhs, rhs = sum.split("=")
      terms = lhs.split("+") << rhs
      if terms.any? { |t| t[0] == ?0 }
         @ranking = @@max_rank
      else
         @ranking = eval("#{lhs} - #{rhs}").abs
      end
   end
   def initialize_copy(original)
      @solution = original.solution.collect { |pair| pair.dup }
      rank
   end
   def inspect
      [@ranking, @solution].inspect
   end
   def to_s
      sum = @@equation.dup
      solution.each { |chr, num| sum.gsub!(chr, num.to_s) }
      "#{@@equation}\n#{sum}"
   end
end
