#!/usr/bin/ruby -Ku
#
# http://ruby.brian-schroeder.de/quiz/mazes/
#
# (c) 2005 Brian Schröder
#
# = Maze creation
#
# == Stupid Solution (Take out edges)
# 1. Create a full maze, where each node is connected to all neighbors
# 2. Randomly remove connections from the maze, until no more connections can be removed without
#    breaking the graph in two cliques.
#   a) Randomly choose an edge {n,n'}
#   c) Remove the edge {n,n'}
#   d) Check if there exists another path between n and n'
#     yes => iterate further
#     no  => add the edge again and try another edge
#
# I implemented this method and it takes really long to calculate the mazes. 
# (On my laptop it takes 90sec for a 30x30 maze)
#
# This is implemented in the file +maze-slow.rb+.
#
#
# == Divide and conquer
# One more approach would be a divide and conquer approach
# - Divide the maze into two submazes either by randomly splitting either 
#   horizontally or vertically 
# - Solve recursively
# - Connect the two mazes by a connection at a random point
# - As base case use the 1x1 maze consisting of only a single node
#
# This creates a valid maze, but will not create every possible valid maze. In fact the mazes
# created by this method are a bit boring.
#
# But this approach is quite fast. It takes 1.5sec for a 30x30 maze on my laptop.
# 
# This is implemented in the file +maze-dc.rb+.
#
# == Intelligent approach
# After some considerations I saw that we are searching a spanning tree here. Minimal
# Spanning trees can be calculated in +O(n log n)+ so calculation of a random spanning tree 
# is possible in at most +O(n log n)+.
#
# Here is the algorithm
#   - Pick a random startingnode n0
#   - Initialize a set of already added nodes to included = {n0}
#   - Initialize a set of queued edges q = {{n,n'} ∈ edges | n = n0}
#   - while edges /= {}
#      - remove a random edge {n,n'} from q, where n ∈ included, n' ∉ included
#      - add n'.edges to q
#      - add n' to inlcuded
#      - add {n, n'} to the graph
#
# This is implemented in +Maze#create_maze!+
#
# This algorithm creates a nice 30x30 maze in 0.5sec
# The algorithm is implemented in the file +maze.rb+.
#
# == Long path maze
# It is possible to create a maze with a very long path by a simple variation of the spanning 
# tree algorithm. We just implement the set of queued edges q as a queue and add the shuffled 
# edges of each added node to this queue. This results in a randomized depth first search and 
# a very long path with a few sidepaths.
#
# The algorithm is implemented in the file +maze-long.rb+.
#
# == Find path with maximum distance.
#
# I implemented one algorithm to find the two nodes with maximum distance in the graph. This
# is done by first calculating the distance of every node to every other node in the tree. 
#
# Anyhow, here is the algorithm:
#
# - Initialize a n x n distance matrix +d+ with 0 on the diagonal, 1 if two nodes are directly 
#    adjacent or infinity otherwise.
# - Initialize a queue q = {n_1,...,n_n} with all the nodes.
# - Until the queue is empty pop one element n_i.
#   - For n_j ∈ {n_1, ..., n_n}
#     - Set the distance n_i, n_j to 
#       min{d[n_i, n_j], d[n_i, n'] + d[n', n_j] | n' ∈ {n_1,...,n_n}}
#     - If the distance has changed and n_i is not in the queue add n_i to the queue
#     - If the distance has changed and n_j is not in the queue add n_j to the queue
#
# This iteratively relaxes the distances using the triangle-equation 
# d(n_i, n_j) ≤ d(n_i, n') + d(n', n_j)
#
# After having all the distances I simply search the maximum and have the start and end node.
#
# The time complexity is as follows:
# - The longest distance in a maze is n
# - => Each node can be relaxed at most n times
# - Only relaxed nodes are added to the queue
# - => Each node is added at most n times to the queue
# - Relaxation of a node takes at most n steps
# - => Total time complexity is O(n³)
#
# This is implemented in the file +maze-distances.rb+
#
# == Find path with maximum distance - second try
#
# The above algorithm is quite slow, so I reimplemented another faster algorithm. Here 
# I use more knowledge about the graph to speed up the search.
#
# I search from each leaf the distance to each other leaf. A longest path will always start
# and end in a leave. As most nodes are not leafes this takes down complexity a lot. 
# Secondly, I know that from leaf end there is only one non-cylic path to each other leaf, so
# a simple depth first search will find all distances in O(n) time. (Each node is visited only
# once). That means I can come away with a total of O(n²) time. And indeed for a 10x10 maze 
# this algorithm finishes in under 1 second, while the above needs nearly 30 seconds.
#
# This file includes the basic maze functionality and the spanning tree algorithm

require 'set'
require 'maze-distances'
require 'maze-distances-2'

class Set
  def pick_one
    self.each do | element |
      return element
    end
    nil
  end
end

module Enumerable
  def shuffle
    sort_by{rand}
  end
end

class Array
  def pop_random
    self.delete_at(rand(self.length))
  end
end

class Maze
  attr_reader :width, :height

  private
  HORIZONTAL = 0
  VERTICAL = 1
  class Node
    include Comparable
    attr_reader :x, :y, :edges, :sorted_edges
    attr_accessor :marked

    def initialize(x, y)
      @x = x; @y = y
      @edges = []
      @marked = false
    end

    def add_edge(edge)
      @edges << edge
    end

    def neighbours
      @edges.inject(Set[]) { |r, edge| edge.active? ? r << edge[0] << edge[1] : r }.delete(self)
    end

    def eql?(o)
      [x,y].eql?([o.x, o.y])
    end

    def hash
      x << 8 + y
    end

    def inspect
      "(#{@marked ? 'X' : ''}#{x}, #{y})"
    end    

    def <=>(o)
      [@x,@y] <=> [o.x, o.y]
    end
  end

  class Edge < Array        
    attr_accessor :active

    def initialize(node1, node2)
      super()
      @active = false
      self << node1 << node2
      node1.add_edge self
      node2.add_edge self
    end

    def inspect
      "<#{self.map{|n|n.inspect}.join('<->')}>"
    end

    def enable
      @active = true
    end

    def disable
      @active = false
    end

    def active?
      @active
    end
  end

  public
  def initialize(width, height)
    @width = width; @height = height 
    @nodes = Array.new(@height) { | y |
      Array.new(@width) { | x |
	Node.new(x, y)
      }
    }
    @edges = []	
    (0...@width).each do | x |
      (0...@height).each do | y |
	@edges << Edge.new(self[x,y], self[x+1,y]) if self[x+1,y]
	@edges << Edge.new(self[x,y], self[x,y+1]) if self[x,y+1]
      end 
    end
  end

  def [](x, y)
    return nil if x < 0 or y < 0 or @width <= x or @height <= y
    return @nodes[y][x]
  end

  def fully_connect
  end

  def self.random_maze(width, height)
    maze = self.new(width, height)
    maze.create_maze!
  end

  def create_maze!
    start_node = self[rand(@width),rand(@height)]
    included = Set[start_node]
    edges = start_node.edges.dup
    while edge = edges.pop_random
      next if included.include?edge[0] and included.include?edge[1]
      edges.concat(edge[included.include?(edge[0]) ? 1 : 0].edges)
      included << edge[0] << edge[1]
      edge.active = true
    end
    self
  end

  class GrowBreadthFirst < Set
    def initialize(start_node = nil)
      super()
      if start_node
	self << start_node
	@queued = Set[start_node]
	@stack = [start_node]
      end
    end

    def grow
      if node = @stack.shift
	node.neighbours.each do | n |
	  next if @queued.include?n
	  @stack << n
	  @queued << n
	  self << n
	end
	true
      else
	false
      end
    end

    def find_all
      () while grow      
      self
    end
  end

  def reachable_from(node)
    GrowBreadthFirst.new(node).find_all
  end

  def path_between(node1, node2)
    c1 = GrowBreadthFirst.new(node1)
    c2 = GrowBreadthFirst.new(node2)
    () while c1.grow and c2.grow and (c1 & c2).empty?
    !((c1 & c2).empty?)
  end

  def all_reachable_from(node)
    Set.new(@nodes.flatten) == reachable_from(node)
  end

  # A funny but inefficent algorithm
  # - Find the connecting node for two growing regions
  # - Mark it
  # - Repeat with start_node, middle_node and middle_node, end_node 
  #   until start_node == end_node
  def mark_path(start_node, end_node)
    start_node.marked = true
    end_node.marked = true
    return if start_node.neighbours.include?(end_node)
    c1 = GrowBreadthFirst.new(start_node)
    c2 = GrowBreadthFirst.new(end_node)
    () while c1.grow and c2.grow and (c1 & c2).empty?
    middle_node = (c1 & c2).pick_one  
    raise 'No path exists' unless middle_node
    mark_path(start_node, middle_node)
    mark_path(middle_node, end_node)
  end

  def to_s
    active_node = 'o'
    inactive_node = ' '
    active_edge_right = 'o'
    inactive_edge_right = ' '
    active_edge_down = 'o'
    inactive_edge_down = ' '    
    wall1 = '▒'    
    wall2 = '▒'    
    result = Array.new(@height*2+1) { |y| Array.new(@width*2+1) { |x| x % 2 == 0 ? wall1 : wall2 } }
    @edges.each do | edge |
      next unless edge.active?
      marked = (edge[0].marked) && (edge[1].marked) 
      if edge[0].y == edge[1].y
	result[2*edge[0].y+1][2*edge[0].x+2] = marked ? active_edge_right : inactive_edge_right
      elsif edge[0].x == edge[1].x
	result[2*edge[0].y+2][2*edge[0].x+1] = marked ? active_edge_down : inactive_edge_down
      else
	raise "No valid grid"
      end
    end
    @nodes.flatten.each do | node |
      result[2*node.y+1][2*node.x+1] = node.marked ? active_node : inactive_node
    end
    result.map{|row|row.join}.join("\n")+"\n"
  end
end

# Sorry this is quite ugly...
def parse_options(init_method)
  begin
    if /^--longest-path$/ =~ ARGV[0]
      @args = ARGV[1..-1]
      @longest = :mark_longest_path
    elsif /^--longest-path-2$/ =~ ARGV[0]
      @args = ARGV[1..-1]
      @longest = :mark_longest_path_2
    else
      @args = ARGV
    end
    raise "Invalid arguments" if @args.length < 2
    maze = Maze.send(init_method, @args[0].to_i, @args[1].to_i)
    maze.send(@longest) if @longest
    case @args.length
    when 2      
    when 4
      start_node = maze[*@args[2].split(',').map{|c| c.to_i-1}]
      end_node = maze[*@args[3].split(',').map{|c| c.to_i-1}]
      maze.mark_path(start_node, end_node)
    else
      raise "Invalid arguments"
    end
    puts maze
  rescue => e
    puts e
    puts "Usage: #{$0} [--longest-path[-2]] width height [start end]"
    puts "  e.g.:" 
    puts "    #{$0} 15 10"
    puts "    #{$0} 30 30 1,1 30,30"
    puts "    #{$0} --longest-path 8 8"
    puts "    #{$0} --longest-path-2 20 20"
  end
end

if __FILE__ == $0
  parse_options(:random_maze)
end
