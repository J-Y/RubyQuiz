#!/usr/bin/ruby -Ku
#
# http://ruby.brian-schroeder.de/quiz/mazes/
#
# (c) 2005 Brian Schröder
#
# This file includes the divide and conquer solution

require 'set'
require 'maze'

class Maze
  
  private
  class Node
    attr_reader :sorted_edges

    def initialize(x, y)
      @x = x; @y = y
      @edges = []
      @sorted_edges = []
    end

    def add_edge(edge)
      if edge[0].y == edge[1].y
	@sorted_edges[edge[0] == self ? 0 : 1] = edge
      else
	@sorted_edges[edge[0] == self ? 2 : 3] = edge
      end
      @edges = @sorted_edges.compact
    end

    def edge_right
      @sorted_edges[0]
    end
    
    def edge_left
      @sorted_edges[1]
    end

    def edge_down
      @sorted_edges[2]
    end
    
    def edge_up
      @sorted_edges[3]
    end
  end
  
  public
  # Used for insertion of other mazes into this maze
  def []=(x, y, node)
    return nil if x < 0 or y < 0 or @width <= x or @height <= y
    my_node = self[x,y]
    my_node.marked = node.marked
    my_node.sorted_edges.zip(node.sorted_edges).each do | (my_edge, edge) |
      next unless my_edge
      my_edge.active = edge ? edge.active : false
    end      
  end

  def insert(ix, iy, other_maze)
    (0...other_maze.width).each do | x |
      (0...other_maze.height).each do | y |
	self[ix+x, iy+y] = other_maze[x,y]
      end
    end
  end


  def self.random_maze_dc(width, height)
    maze = self.new(width, height)
    maze.create_maze_dc!
  end

  def split_horizontal
    return create_maze_dc! if @width <= 1
    left_maze = Maze.random_maze_dc(width / 2, height)
    right_maze = Maze.random_maze_dc(width - width / 2, height)
    self.insert(0,0,left_maze)
    self.insert(width/2,0,right_maze)
    r = rand(height)
    self[width/2-1, r].edge_right.active = true
  end

  def split_vertical
    return create_maze_dc! if @height <= 1
    top_maze = Maze.random_maze_dc(width, height / 2)
    bottom_maze = Maze.random_maze_dc(width, height - height / 2)
    self.insert(0,0,top_maze)
    self.insert(0,height/2,bottom_maze)
    r = rand(width)
    self[r, height/2-1].edge_down.active = true
  end
  
  def create_maze_dc!
    return self if @width == 1 and @height == 1
    if rand < 0.5
      split_horizontal
    else
      split_vertical
    end
    self
  end
end

if __FILE__ == $0
  parse_options(:random_maze_dc)
end
