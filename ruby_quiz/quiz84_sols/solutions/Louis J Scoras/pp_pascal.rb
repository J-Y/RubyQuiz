#!/usr/bin/env ruby
#
# pascal.rb - Pretty-print Pascal's Triangle
#
# Copyright (C) 2006 Louis J. Scoras
#
# This program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more
# details.
#
# [http://www.gnu.org/copyleft/gpl.html]


# Here's my solution for Ruby Quiz 84.  I realize that you can calculate the
# last row in the expansion using the binomial theorem, but you'll need to
# iterate through each row anyway to print the numbers out, so I just went
# with a caching method.
#
# I was going to implement a persistant disk cache, but alas I find myself
# currently stuck on a windows machine, which takes all the fun out of it--
# for me at least :)
#
# Thanks to Dirk and James for a great quiz.

require 'enumerator'

class PascalsRow
 attr_reader :numbers

 def initialize(numbers = [1], depth = 0)
   @numbers = numbers
   @depth   = depth
 end

 def even?
   @depth % 2 == 0
 end

 def calculate_next
   sums = if @numbers.length == 1
     [1]
   else
      @numbers.enum_cons(2).collect {|j,k| j+k}
   end

   sums = sums << sums.last if even? && @depth != 0
   self.class.new([1] + sums, @depth + 1)
 end

 def canonical
   half = @numbers.dup
   half.pop
   half.pop unless even?
   @numbers + half.reverse
 end

 def to_s
   canonical.join(' ')
 end

 def padded_string(word_size)
   canonical.collect do |n|
     digits  = n.to_s
     padding = ((word_size - digits.length) / 2.0).ceil
     make_padding(padding) +
	digits +
	make_padding(word_size - digits.length - padding, 1)
   end.join
 end

 private
 def make_padding(size, min_length = 0)
   ' ' * [size, min_length].max
 end
end

class PascalsTriangle
 def initialize
   @rows = [PascalsRow.new]
 end

 def iterate_rows(n, &block)
   current_row = @rows.first
   block.call(current_row) if block

   n.times do |n|
     current_row = if @rows[n+1]
       @rows[n+1]
     else
       current_row = current_row.calculate_next
       @rows[n+1]  = current_row
     end
     block.call(current_row) if block
   end
   current_row
 end

 def pretty(n)
   last_line = iterate_rows(n)
   word_size = last_line.numbers.last.to_s.length
   width     = last_line.padded_string(word_size).length

   iterate_rows(n) do |row|
     padded = row.padded_string(word_size)
     puts (' ' * ((width - padded.length) / 2)) + padded
   end
 end
end

pt = PascalsTriangle.new
pt.pretty((ARGV[0] ? ARGV[0].to_i : 10) - 1)
