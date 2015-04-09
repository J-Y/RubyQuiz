#!/usr/bin/ruby -Ku
#
# http://ruby.brian-schroeder.de/quiz/mazes/
#
# (c) 2005 Brian Schröder


class Maze
  PathDistance = Struct.new(:start_node, :end_node, :last_node, :value)
  
  def mark_longest_path_2
    # Initialize pathes with all the path endings
    found_paths = []
    paths = @nodes.flatten.map { | n |
      n.neighbours.length == 1 ? PathDistance.new(n, n, nil, 0) : nil 
    }.compact
    # Find all end to end paths
    while path = paths.pop
      neighbours = path.end_node.neighbours
      if neighbours == Set[path.last_node]
	found_paths << path
      else
	neighbours.each do | next_node |
	  next if next_node == path.last_node
	  paths << PathDistance.new(path.start_node, next_node, path.end_node, path.value+1)	  
	end
      end
    end 
    # Mark longest path
    longest_path = found_paths.sort_by{|path|path.value}[-1]
    self.mark_path(longest_path.start_node, longest_path.end_node)
    longest_path
  end
end
