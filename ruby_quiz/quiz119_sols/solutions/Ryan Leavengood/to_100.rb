# Based on:
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/139290
# Author: Endy Tjahjono
class String
 def perm
   return [self] if self.length < 2
   ret = []

   0.upto(self.length - 1) do |n|
     rest = self.split(//u) # for UTF-8 encoded strings
     picked = rest.delete_at(n)
     rest.join.perm.each { |x| ret << picked + x }
   end

   ret
 end
end

# All the rest is Ryan Leavengood code :)
class EquationSolver
 attr_reader :num_seq, :operators, :result

 def initialize(num_seq = "123456789", operators = "--+", result_wanted = 100)
   @num_seq, @operators, @result_wanted = num_seq, operators, result_wanted
 end

 SEP = '*' * 24

 def solve
   equations = 0
   ops = op_combinations(@operators).map{|a| a.split('')}
   generate_groups(@num_seq).each do |group|
     ops.each do |op|
       eq = group.zip(op).join(' ')
       result = eval(eq)
       puts SEP if result == @result_wanted
       puts "#{eq}= #{result}"
       puts SEP if result == @result_wanted
       equations += 1
     end
   end
   puts "#{equations} possible equations tested"
 end

 def op_combinations(operators)
   operators.perm.uniq
 end

 # Returns an array of numeric strings representing how the given
 # number can be split into the given number of groups
 def num_split(number, num_groups)
   return [number.to_s] if num_groups == 1
   return ["1" * num_groups] if number == num_groups
   result = []
   ((number + 1)-num_groups).times do |i|
     cur_num = i + 1
     num_split(number - cur_num, num_groups - 1).each do |group|
       result << "#{cur_num}#{group}"
     end
   end
   result
 end

 def generate_groups(num_seq, num_groups = @operators.length+1)
   num_split(num_seq.length, num_groups).map do |split_on|
     # Turn the result from num_split into a regular expression,
     # with each number becoming grouped dots
     reg_exp = split_on.split('').map{|n| "(#{'.' * n.to_i})"}.join
     num_seq.scan(/#{reg_exp}/).first
   end
 end
end

require 'test/unit'

class SolverTester < Test::Unit::TestCase
 def setup
   @es = EquationSolver.new
 end

 def test_string_perm
   assert_equal(["1"],
     "1".perm)
   assert_equal(["12","21"],
     "12".perm)
   assert_equal(["123", "132", "213", "231", "312", "321"],
     "123".perm)
 end

 def test_op_combinations
   assert_equal(["1"],
     @es.op_combinations("1"))
   assert_equal(["12","21"],
     @es.op_combinations("12"))
   assert_equal(["123", "132", "213", "231", "312", "321"],
     @es.op_combinations("123"))
   assert_equal(["223", "232", "322"],
     @es.op_combinations("223"))
   assert_equal(["--+", "-+-", "+--"],
     @es.op_combinations("--+"))
 end

 def test_num_split
   assert_equal(["11"],
     @es.num_split(2,2))
   assert_equal(["111"],
     @es.num_split(3,3))
   assert_equal(["12", "21"],
     @es.num_split(3,2))
   assert_equal(["13", "22", "31"],
     @es.num_split(4,2))
   assert_equal(["112", "121", "211"],
     @es.num_split(4,3))
 end

 def test_generate_groups
   assert_equal([["1", "2", "34"], ["1", "23", "4"], ["12", "3", "4"]],
     @es.generate_groups("1234", 3))
 end
end

if $0 == __FILE__
 # By default do not run the test cases
 Test::Unit.run = true

 if ARGV.length > 0
   if ARGV[0] == 'ut'
     # Run the test cases
     Test::Unit.run = false
   else
     begin
       if ARGV.length != 3
         raise
       else
         if ARGV[0] =~ /^\d*$/ and
           ARGV[1] =~ /^[\+\-\*\/]*$/ and
           ARGV[2] =~ /^-?\d*$/

           EquationSolver.new(ARGV[0], ARGV[1], ARGV[2].to_i).solve
         else
           raise
         end
       end
     rescue
       puts "Usage: #$0 <number sequence> <string of operators> <result wanted>"
       puts "\tOr just the single parameter 'ut' to run the test cases."
       exit(1)
     end
   end
 else
   # Solve the default case
   EquationSolver.new.solve
 end
end
