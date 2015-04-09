#!/usr/bin/env ruby
#
# Louis J. Scoras <louis.j.scoras@gmail.com>
# Monday, October 16, 2006
# Solution for Ruby Quiz number 98
#
##############################################################################
# astar.rb - quiz solution to RubyQuiz # 98
#   the interesting bits are in this file and see the map.rb part
#   for the use of Array.cartesian_product

require 'set'
require 'enumerator'
require 'pqueue'     # included below
require 'map'        #    "       "
require 'summary'    #    "       "

# Here we are, a nicely generalized A* method =) We could have easily just
# required that a node has a neigbors method (duck typing), but I wanted to
# make this as general as possible. So astar can have an additional proc
# passed in, which when called on a node returns an enumerator to its
# successors. Note the default value is what we would have had before.
#
def astar(start,finish,succ=nil,&h)
 closed = Set.new
 queue  = PQueue.new(&h) << [start]
 succ ||= lambda {|n| n.neighbors}

 until queue.empty?
   path = queue.dequeue
   node = path.last
   next if closed.include? node
   return path if node == finish
   closed << node
   successors = succ[node]
   successors.each do |location|
     queue << (path.dup << location)
   end
 end
end

# Nested loops for iterating over a multi-dimentional array hurt the head;
# this abstracts it away.  This also leads to a cool little method--well at
# least I think so--for computing neighboring nodes.
#
# cartesian_product([-1,0,1],[-1,0,1])
#    # => [ [-1,-1], [0, -1], [1, -1],
#           [-1, 0], [0,  0], [1,  0],
#           [-1, 1], [0,  1], [1,  1]]
#
def cartesian_product(*sets)
 case sets.size
 when 0
   nil
 when 1
   sets[0].collect {|i| [i]}
 else
   current = sets.pop
   tupples = []
   current.each do |element|
     cartesian_product(*sets).each do |partials|
       partials.each do |n|
         tupples << [n, element]
       end
     end
   end
 tupples
 end
end

map = Map.new(File.read(ARGV[0]))

path = astar(map.start,map.goal) do |path_a, path_b|
 score_a, score_b =
  [path_a, path_b].collect {|path|
      current  = path.last
      traveled = path.inject(0) {|t, node| t + node.cost}
      traveled + current.distance(map.goal)
  }
 score_b <=> score_a  # Ordered for min_heap
end

summary path
