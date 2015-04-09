#!/usr/bin/ruby -Ku
#
# http://ruby.brian-schroeder.de/quiz/mazes/
#
# (c) 2005 Brian Schröder
#
# This file contains a variation of the spanning tree algorithm, that leads to a very long 
# path in the maze.

require 'maze'
class Maze
  def self.random_maze_long(width, height)
    maze = self.new(width, height)
    maze.create_maze_long!
  end

  def create_maze_long!
    start_node = self[0, 0]
    included = Set[start_node]    
    edges = start_node.edges.dup
    while edge = edges.pop
      next if included.include?edge[0] and included.include?edge[1]
      edges.concat(edge[included.include?(edge[0]) ? 1 : 0].edges.shuffle)
      included << edge[0] << edge[1]
      edge.active = true
    end
    self
  end
end

if __FILE__ == $0
  parse_options(:random_maze_long)
end
