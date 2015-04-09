#!/usr/bin/ruby
#######################################################################
# Countdown Solver Experiments (Memoized)
# (c) 2004 Brian Schröder
# http:://ruby.brian-schroeder.de/
#######################################################################
# This code is under GPL
#######################################################################

require 'test/unit'
require 'pp'

class Numeric
  def evaluate() self end

  def each_leave() yield self end
end

# Build a term tree using these nodes
class Term
  attr_reader :left, :right, :operation
  
  def initialize(left, right, operation)
    @left = left
    @right = right
    @operation = operation
  end

  def to_s
    "(#{@left} #{operation} #{@right})"
  end

  def evaluate
    (@left.evaluate).send(@operation, (@right.evaluate))
  end

  def each_leave(&block)
    [left, right].each do | child |
      if child.is_a?Term
        child.each_leave(&block)
      else
        block.call(child)
      end
    end
  end
end

class Array
  def each_partition
    return nil if empty?
    head, *tail = *self
    tail.each_subset_and_rest do | subset, rest |
      yield [subset.unshift(head), rest] unless rest.empty?
    end
  end

  protected
  def each_subset_and_rest
    if empty?
      yield([], [])
      return nil
    end
    head, *tail = *self
    tail.each_subset_and_rest do | s1, s2 |
      yield([head] + s1, s2) 
      yield(s1, [head] + s2)
    end
  end
end

COMM_OPERATIONS = [:+, :*]
NON_COMM_OPERATIONS = [:-, :/]

# Recursive terms_over function, that calls a block each time a new term has been stitched together.
# Returns each term multiple times.
def terms_over(source)
  if source.length == 1
    yield source[0]
  else
    source.each_partition do | p1, p2 |
      terms_over(p1) do | op1 |
        yield op1
        terms_over(p2) do | op2 |
          yield op2
          COMM_OPERATIONS.each do | op |
            yield Term.new(op1, op2, op)
          end
          NON_COMM_OPERATIONS.each do | op |
            yield Term.new(op1, op2, op)
            yield Term.new(op2, op1, op)
          end
        end
      end
    end
  end
end

# Recursiv Countdown Solver
def solve_countdown(target, source) 
  best = source[0]
  best_distance = 1.0/0.0
  terms_over(source) do | term |
    distance = (term.evaluate - target).abs
    if distance < best_distance
      best_distance = distance
      best = term
      puts "#{best} = #{best.evaluate} = #{target} +/- #{best_distance}"
      return best if best_distance == 0

      source_rest = source.dup
      term.each_leave do | n | source_rest.delete_at(source_rest.index(n)) end

      unless source_rest.empty?
      term = Term.new(best, solve_countdown(target - best.evaluate, source_rest), :+)
      distance = (term.evaluate - target).abs
      if distance < best_distance
        best_distance = distance
        best = term
        puts "Corrected to: #{best} = #{best.evaluate} = #{target} +/- #{best_distance}"
        return best if best_distance == 0
      end
      
      term = Term.new(best, solve_countdown(best.evaluate - target, source_rest), :-)
      distance = (term.evaluate - target).abs
      if distance < best_distance
        best_distance = distance
        best = term
        puts "Corrected to: #{best} = #{best.evaluate} = #{target} +/- #{best_distance}"
        return best if best_distance == 0
      end
      end
    end
  end
  return best
end

if ARGV.length > 0
  solve_countdown(ARGV[0].to_f, ARGV[1..-1].map{|i|i.to_f}.sort_by{|i|-i})
else
  class TC_countdown < Test::Unit::TestCase
    def test_countdown   
      assert_equal(solve_countdown(522.0, [100, 5, 5, 2, 6, 8].map{ | e | e.to_f }).evaluate, 522.0, 'Countdown solver not working')
      #assert_equal(solve_countdown(523.0, [100, 5, 5, 2, 6, 8].map{ | e | e.to_f }).evaluate, 523.0, 'Countdown solver not working')
    end
    
    PARTITIONS3 = [[[1], [2,3]], [[1,2], [3]], [[1,3], [2]]]
    PARTITIONS5 = [[[1], [2, 3, 4, 5]], [[1, 2], [3, 4, 5]], [[1, 2, 3], [4, 5]], [[1, 2, 3, 4], [5]], [[1, 2, 3, 5], [4]],
      [[1, 2, 4], [3, 5]], [[1, 2, 4, 5], [3]], [[1, 2, 5], [3, 4]], [[1, 3], [2, 4, 5]], [[1, 3, 4], [2, 5]], [[1, 3, 4, 5], [2]],
      [[1, 3, 5], [2, 4]], [[1, 4], [2, 3, 5]], [[1, 4, 5], [2, 3]], [[1, 5], [2, 3, 4]]]
    def test_each_partition
      partitions = []
      [1,2,3].each_partition do | p1, p2 | partitions << [p1.sort, p2.sort] end
      assert_equal(PARTITIONS3,  partitions.sort)
      partitions = []
      [1,2,3,4,5].each_partition do | p1, p2 | partitions << [p1.sort, p2.sort] end
      assert_equal(PARTITIONS5,  partitions.sort)
    end
  end
end
