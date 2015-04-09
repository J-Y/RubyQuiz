#!/usr/bin/ruby
#######################################################################
# Countdown Solver Experiments (Genetic Algorithm)
# (c) 2004 Brian Schröder
# http:://ruby.brian-schroeder.de/
#######################################################################
# This code is under GPL
#######################################################################

require 'test/unit'
require 'pp'

class Array
  def random_pick
    self[rand(self.length)]
  end
end

# Hackisch. I could have used an encapsulating object, but I wanted it simple.
class Numeric
  def evaluate() self end

  attr_accessor :parent
end


OPERATIONS = [:+, :-, :*, :/]

class Individual
  LEFT_RIGHT_ACCESSORS = [[:left, :left=], [:right, :right=]]
  attr_reader :operation
  
  def initialize(source)
    if source.is_a?Individual
      @nodes = []
      @operation = duplicate_tree(source.operation)
    else
      @nodes = []
      @operation = create_tree(source)
    end
  end

  def evaluate
    @operation.evaluate
  end

  def to_s
    @operation.to_s
  end

  def display
    @operation.display
  end
  
  def mutate!
    # Change operations or exchange subtrees
    case 1#rand(2)
    when 0: @nodes.random_pick.mutate
    when 1
      # UGH, Ugly that
      n = @nodes.random_pick
      path_left = random_path(n.left)
      path_right = random_path(n.right)

      path_left.unshift([n.left, :left])
      path_right.unshift([n.right, :right])

      i = rand(path_left.length)
      j = rand(path_right.length)

      path_left.unshift([n, :nil])
      path_right.unshift([n, :nil])

      path_left[i][0].send(path_left[i+1][1].to_s + '=', path_right[j+1][0])
      path_right[j][0].send(path_right[j+1][1].to_s + '=', path_left[i+1][0])
    end
    self
  end

  def mutate
    self.dup.mutate!
  end

  def dup
    self.class.new(self)
  end

  private
  def random_path(node)
    result = []
    while node.respond_to?:left
      case rand(2)
      when 0: node = node.left
        result << [node, :left] if node.is_a?Operation
      when 1: node = node.right
        result << [node, :right] if node.is_a?Operation
      end
    end
    return result
  end
  
  private
  def create_tree(source)
    return source[0] if source.length == 1
    begin
      p1, p2 = source.partition{ rand(2) == 0 }
    end while p1.empty? or p2.empty?
    operation = Operation.new(create_tree(p1), create_tree(p2), OPERATIONS.random_pick)
    @nodes << operation
    return operation
  end

  private
  def duplicate_tree(operation)
    return operation unless operation.is_a?Operation
    operation = Operation.new(duplicate_tree(operation.left), duplicate_tree(operation.right), operation.operation)
    @nodes << operation
    operation
  end
end

# Build a operation tree using these nodes
class Operation
  attr_accessor :left, :right, :operation
  
  def initialize(left, right, operation)
    @left = left
    @right = right
    @operation = operation
  end

  def to_s
    "(#{@left} #{operation} #{@right})"
  end

  def display
    "#{to_s} = #{evaluate}"
  end

  def evaluate
    (@left.evaluate).send(@operation, (@right.evaluate))
  end

  def mutate
    @operation = OPERATIONS.random_pick
    self
  end
end


def solve_countdown(target, source, iterations = 10000, pop_size = 20)
  source.map!{|e|e.to_f}
  # Create a random population
  population = Array.new(pop_size) { Individual.new(source) }
  best = nil
  best_diff = 1.0/0.0
  iterations.times do
    # Only the fittest half of the population survives    
    population = population.sort_by{ | s | (s.evaluate - target).abs }[0...pop_size / 2]    
    puts "Population (Sorted):",population.map{|i| i.display}
    difference = (population[0].evaluate - target).abs
    if difference < best_diff
      best = population[0]
      best_diff = difference
      puts "Best so far #{best} = #{best.evaluate}  (#{target}/#{best_diff})"
    end
    population = population.map{|ind| ind.mutate } + population.map{|ind| ind.mutate }
  end
  return best
end

class TC_countdown < Test::Unit::TestCase
  def test_countdown   
    assert_equal(522, solve_countdown(522, [100, 5, 5, 2, 6, 8]).evaluate, 'Countdown solver not working')
    i = Individual.new([100.0, 5.0, 1.0])
    puts i.display
    im = i.mutate
    puts im.display
  end
end
