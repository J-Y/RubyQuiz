#!/usr/bin/env ruby

#requires are only necessary to construct the
#operator permutation table from the list of operators
#if you want to hard code that (and not do the extra credit)
#then no extra libraries are necessary
require 'rubygems'
require_gem 'facets'
require 'facets/core/enumerable/permutation'
require 'enumerator'

Digits= (ARGV.shift || "123456789").split(//)
RequestedResult=(ARGV.shift || 100).to_i
rawoperators=(ARGV.shift || "+--")

#construct the operator permutation table from the list of operators
Operators=rawoperators.split(//).map{|x| " #{x} "}
OperatorPerms=Enumerable::Enumerator.new(Operators,:each_permutation).
   map{|p| p}.uniq

class Array

   #Yields all partitionings of the array which have +num+ partitions
   #and retain the order of the elements
   #
   #To relax the ordering constraint, use this in combination
   #with Enumerable#each_permutation
   def each_partition num
      if num==1
	 yield [self]
	 return self
      end
      (0..length-num).each do |x|
	 firstset=self[0..x]
	 self[(x+1)..-1].each_partition(num-1) do |y|
	    yield [firstset,*y]
	 end
      end
      return self
   end
end

#The actual solution to the problem
counter=0
found=0
Digits.each_partition(Operators.length+1) do |digitspart|
   OperatorPerms.each do |operatorsperm|
      counter+=1
      expression=digitspart.zip(operatorsperm).flatten.join
      result=eval(expression)
      puts "************************" if RequestedResult==result
      puts "#{expression} = #{result}"
      puts "************************" if RequestedResult==result
      found+=1 if RequestedResult==result
   end
end
puts "#{counter} possible equations tested"
puts "#{found} equation(s) equaled #{RequestedResult}"
