#!/usr/bin/env ruby
#
# Ruby Quiz #60, Numeric Maze
# http://www.rubyquiz.com/quiz60.html
#
# You have a starting point and a target, say 2 and 9.
# You have a set of three operations:
# double, halve (odd numbers cannot be halved), add_two.
#
# Problem: Move from the starting point to the target,
# minimizing the number of operations.
# Examples:
# solve(2,9)  # => [2,4,8,16,18,9]
# solve(9,2)  # => [9,18,20,10,12,6,8,4,2]
#
#
# This solution builds a tree with each node having up to
# three subnodes, one for each operation. It builds the
# tree one level at a time and checks for a solution before
# proceeding down to the next level. This brute force
# approach performs much better after adding two optimizations
# suggested by Dominik Bathon and others: track what numbers
# have been visited and do not build subnodes for previously
# visited numbers; and use a ceiling to disregard numbers
# large enough that they will not be needed in the solution.
#

module NumericMaze

  class Node
    attr_accessor :parent, :value, :children

    def initialize(parent, value)
      @parent = parent
      @value = value
      @children = {}
    end

    def double
      @children[:double] = Node.new(self, @value * 2)
    end

    def halve
      return :halve_failed if @value % 2 != 0
      @children[:halve] = Node.new(self, @value / 2)
    end

    def add_two
      @children[:add_two] = Node.new(self, @value + 2)
    end

  end

  def NumericMaze.solve(start, target)
    ceiling = [start, target].max*2+2
    # Initialize node arrays with root node
    node_arrays = []
    node_arrays[0] = []
    node_arrays[0] << Node.new(:root, start)
    # Initialize hash of visited numbers; do not
    # visit a number twice (thanks to Dominik Bathon)
    visited_numbers = {}
    # Check for a solution at each level
    level = 0
    while true
      # Examine nodes at this level and
      # build subnodes when appropriate
      node_arrays[level+1] = []
      node_arrays[level].each do |node|
        # Skip if method "halve" failed
        next if node == :halve_failed
        # Skip if number exceeds ceiling
        next if node.value > ceiling
        # Skip if this number has been tried already
        next if visited_numbers[node.value]
        visited_numbers[node.value] = true
        # Has a solution been found? If yes,
        # print it and exit
        if node.value == target
          # Build array of values used
          # (from bottom up)
          value_array = []
          node_ptr = node
          while true
            break if node_ptr.parent == :root
            value_array << node_ptr.value
            node_ptr = node_ptr.parent
          end
          # Display answer and exit
          p [start] + value_array.reverse
          exit
        end
        # Collect new results at this level
        node_arrays[level+1] << node.double
        node_arrays[level+1] << node.halve
        node_arrays[level+1] << node.add_two
      end
      level += 1
    end
  end

end

########################################

if ARGV.length != 2
  puts "Usage: #{$0} <start> <target>"
  exit
end

NumericMaze.solve(ARGV[0].to_i, ARGV[1].to_i)
