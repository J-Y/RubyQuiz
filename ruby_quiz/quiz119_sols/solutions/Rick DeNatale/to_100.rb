require 'rubygems'
require 'permutation'

class String

 # yield each partitioning of the receiver into count partitions
 #
 # This is a recursive implementation using composition of the block argument.
 #
 # The approach is to iteratively split the string into two parts,
 # an initial substring of increasing length, and the remainder.
 # For each initial substring we yield an array which is the concatenation
 # of the initial substring and the partitioning of the remainder of the string
 # into count-1 partitions.
 def each_partition(count, &b)
   # if the count is 1 then the only partition is the entire string.
   if count == 1
     yield [self]
   else
     # Iterate over the initial substrings, the longest initial substring must leave
     # at least count-1 characters in the remaining string.
     (1..(size-(count-1))).each do |initial_size|
       self[initial_size..size].each_partition(count-1) {|remaining|
         b.call([self[0,initial_size]] + remaining)}
     end
   end
 end
end

# print combinations of digits and operators which evaluate to a goal
#
# Arguments are supplied by a hash the keys are:
#
#  Main arguments
#    :goal - the number being sought, default is 100
#    :digits - a string of digits, default is "123456789"
#    :ops - an array of strings representing the operators to be inserted into
#           digits, default is %w[- - +]
#
#  Additional arguments
#    :verbose - unless false, print all attempts, default is false
#    :return_counts - unless false, return an array of value, count arrays for
#                     values with multiple solutions, used to find interesting
#                     inputs, default is false
def get_to(options={})
 options = {
   :goal => 100,
   :digits => '123456789',
   :ops => %w[- - +],
   :verbose => false,
   :return_counts => false
 } .merge(options)
 digits= options[:digits]
 goal, digits, ops, verbose, return_counts = *options.values_at(:goal, :digits, :ops, :verbose, :return_counts)
 operators = Permutation.for(ops).map{|perm| perm.project}.uniq
 puts "Looking for #{goal}, digits=#{digits}, operators=#{ops.inspect}"
 counts = Hash.new(0)
 found_in_a_row = 0
 digits.each_partition(ops.size + 1) do |numbers|
   operators.each do |ops|
     op_index = -1
     eqn = numbers.zip(ops).flatten.compact.join(' ')
     val = eval(eqn)
     counts[val] += 1 if return_counts
     found = val == goal
     puts "********************************"  if found_in_a_row == 0 && found
     puts "********************************" unless found_in_a_row == 0 || found
     puts "#{eqn} = #{val}" if verbose || goal == val
     found_in_a_row = found ? found_in_a_row + 1 : 0
   end
 end
 return_counts ? counts.select {|key,value| value > 1} : nil
end

get_to
get_to(:verbose=> true)
get_to(:goal => 357, :ops => %w[+ - +], :verbose=> true)
get_to(:goal => 302, :digits => '987654321')
get_to(:goal => 98, :verbose => true)
p get_to(:goal => 336)
get_to(:goal => -355)
