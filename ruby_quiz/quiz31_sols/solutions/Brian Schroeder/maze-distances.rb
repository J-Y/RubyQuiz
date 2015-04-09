#!/usr/bin/ruby -Ku
#
# http://ruby.brian-schroeder.de/quiz/mazes/
#
# (c) 2005 Brian Schröder


class Maze
  INFINITY = 1.0 / 0.0
  
  def mark_longest_path
    # Initialize distance Table with direct distances
    flattened_nodes = @nodes.flatten
    distances = flattened_nodes.map { | n1 | 
      flattened_nodes.map { | n2 | 
	if n1 == n2
	  0
	elsif n1.neighbours.include?n2
	  1
	else
	  INFINITY
	end
      } 
    }
    if false
      # Update the distance table until it has stabilized
      begin
	changed = false
	distances.each_with_index do | dists_n1, n1 |
	  dists_n1.each_with_index do | dist_n1_n2, n2 |
	    dists_n2 = distances[n2]
	    dists_n1.zip(dists_n2).each_with_index do | (dist_n1_n3, dist_n2_n3), n3 |
	      joint_distance = dist_n1_n3 + dist_n2_n3
	      if joint_distance < distances[n1][n2]
		distances[n1][n2] = joint_distance 
		distances[n2][n1] = joint_distance
		changed = true
	      end
	    end
	  end
	end
      end while changed
    end
    queue = (0...flattened_nodes.length).to_a
    # Update the distance table until it has stabilized
    queued = Array.new(flattened_nodes.length)
    while n1 = queue.pop 
      queued[n1] = false
      dists_n1 = distances[n1]
      dists_n1.each_with_index do | dist_n1_n2, n2 |
	dists_n2 = distances[n2]
	dists_n1.zip(dists_n2).each_with_index do | (dist_n1_n3, dist_n2_n3), n3 |
	  joint_distance = dist_n1_n3 + dist_n2_n3
	  if joint_distance < distances[n1][n2]
	    distances[n1][n2] = joint_distance 
	    distances[n2][n1] = joint_distance
	    queue << n1 unless queued[n1]
	    queue << n2 unless queued[n2]
	    queued[n1] = true
	    queued[n2] = true
	  end
	end
      end
    end
    # Search the longest path
    longest = 0
    start_node = flattened_nodes[0]
    end_node   = flattened_nodes[0]
    distances.each_with_index do | dists_n1, n1 |
      dists_n1.each_with_index do | dist_n1_n2, n2 |
	if dist_n1_n2 > longest
	  longest = dist_n1_n2
	  start_node = flattened_nodes[n1]
	  end_node = flattened_nodes[n2]		     
	end
      end
    end
    # Mark the longest path
    self.mark_path(start_node, end_node)
    [start_node, end_node]
  end
end
