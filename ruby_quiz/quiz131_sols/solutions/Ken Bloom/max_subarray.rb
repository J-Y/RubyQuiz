#!/usr/bin/env ruby

require 'matrix'

#strangely, none of these methods are in the facets gem.

module Enumerable
   def argmax 
      curmax=nil
      curval=nil
      each do |x|
	 t=yield x
	 if not curmax or (curmax < t)
	    curmax=t
	    curval=x
	 end
      end
      curval
   end

   def sum
      inject{|a,b|a+b}
   end

   def subarrays
      result=[]
      (0...length).each do |start|
	 ((start + 1)..length).each do |finish|
	    result << self[start...finish]
	 end
      end
      result
   end
end

class Matrix
   include Enumerable
   def submatrices
      result=[]
      (0...row_size).each do |srow|
      (srow+1..row_size).each do |erow|
      (0...column_size).each do |scolumn|
      (scolumn+1..column_size).each do |ecolumn|
	 result << minor(srow...erow,scolumn...ecolumn)
      end end end end
      result
   end
   def each
      (0...row_size).each do |row|
      (0...column_size).each do |column|
	 yield self[row,column]
      end end
   end
end

ARRAY=[-1, 2, 5, -1, 3, -2, 1]
p ARRAY.subarrays.argmax{|x| x.sum}

MATRIX=Matrix[[1,-2,3],[5,2,-4],[5,-5,1]]
p MATRIX.submatrices.argmax{|x| x.sum}
