#!/usr/bin/env ruby
#

require 'permutation'

class EqGenerator
  def initialize(digits, operators, result)
    @digits = digits
    @operators = operators
    @result = result
  end

  def solve
    # create array of possible solutions, then print, testing against desired result as we go
    correct = 0
    @eqs = permute_ops(@operators).collect { |o| insert_ops(@digits, o) }.flatten
    @eqs.each do |e|
      res = eval(e)
      if (res == @result)
        correct += 1
        puts "***#{e}=#{res}***"
      else
        puts "#{e}=#{res}"
      end
    end
    puts "A total of #{@eqs.length} equations were tested, of which #{correct} " + ((correct == 1)? "was": "were") + " correct"
  end

  private
  def permute_ops(ops)
    # use gem from <http://permutation.rubyforge.org/> to get unique permutations of operators and return as array
    perm = Permutation.new(ops.length)
    return perm.map { |p| p.project(ops) }.uniq
  end

  def insert_ops(digs, ops)
    res = Array.new
    # if only one op to insert, just put it in each available spot and return array of equations
    if ops.length == 1 then
      0.upto(digs.length-2) { |i| res << digs[0..i] + ops + digs[i+1..digs.length]}
    # if more than 1 op, for each legal placement of first op: recursively calculate placements for other ops and digits, then prepend first op
    else
      0.upto(digs.length - (ops.length+1)) { |i| res << insert_ops(digs[i+1..digs.length], ops[1..ops.length]).collect { |e| digs[0..i] + ops[0..0] + e } }
    end
    return res.flatten
  end

end

eg = EqGenerator.new("123456789", "--+", 100)
eg.solve
