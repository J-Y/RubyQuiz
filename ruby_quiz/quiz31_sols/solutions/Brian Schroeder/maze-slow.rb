#!/usr/bin/ruby -Ku
#
# http://ruby.brian-schroeder.de/quiz/mazes/
#
# (c) 2005 Brian Schröder
#
# This file includes the stupid solution

require 'maze'

class Maze
  def fully_connect
    @edges.each do | edge |
      edge.active = true
    end
  end

  def self.random_maze_slow(width, height)
    maze = self.new(width, height)
    maze.create_maze_slow!
  end

  def create_maze_slow!
    fully_connect
    begin
      # Create a list of edges in the maze
      edges = @edges.inject([]){|r, edge| edge.active? ? r << edge : r}.shuffle

      # Try to remove each edge
      changed = false
      edges.each do | edge |
	edge.disable
	if path_between(*edge)
	  changed = true
	else 
	  edge.enable
	end
      end
    end while changed
    self
  end
end

if __FILE__ == $0
  parse_options(:random_maze_slow)
end
