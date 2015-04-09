#require 'set'
#
# requires the implementation of an each_neighbour method which must yield the neighbours of an object, and optionally the 'cost' of the link.
# it doesn't require the full object list - it builds the list as it goes. Would probably be faster if it had the whole list, but I wanted to keep the
# code generic
#
module SimpleDijkstra
	class Vertex
		attr_reader :object, :parent
		attr_reader :distance
		def initialize(object, distance, parent=nil)
			@object = object
			@distance = distance
            @parent = parent
		end
	end
	# returns a hash where the keys are all reachable nodes and the values are the shortest distances to those nodes
	# yields each node and the calculated distance hash as they are calculated
	def find_distances()
		known = Hash.new
		unknown = []
		unknown << Vertex.new(self, 0)
		a = b = weight = neighbour = min = nil
		until unknown.empty?
			min = unknown.shift
			p [min.distance, unknown.size, known.size] if $DEBUG
			known[min.object] = min
			yield min, known
            new_distance = min.distance + 1
			min.object.each_neighbour do |neighbour|
				unless known.has_key?(neighbour)
                    known[neighbour] = new_distance
					unknown << Vertex.new(neighbour, new_distance, min)
				end
			end
		end
		return known
	end
	# finds the shortest path from the current node to the specified end_node
	def shortest_path(end_node)
		find_distances() do |found_vertex, known_vertexes|
			if(found_vertex.object == end_node)
                next_vertex = found_vertex
                path = []
                while next_vertex
                    path.unshift(next_vertex.object)
                    next_vertex = next_vertex.parent
                end
                return path
			end
		end
		return nil
	end
end

module Dijkstra 
    include SimpleDijkstra
	class SortedVertexArray
		def initialize
			@arr = []
		end
		def shift
			@arr.shift
		end
		def empty?
			@arr.empty?
		end
		def size
			@arr.size
		end
		def <<(other)
            @arr.each_with_index {|x,i|
                if(x.distance >= other.distance)
                    @arr[i+1..-1] = @arr[i..-1].reject {|x| x.object == other.object}
                    @arr[i] = other
                    return
                elsif(x.object == other.object)
                    return
                end
            }
            @arr << other
		end			
	end
	def find_distances()
		known = Hash.new
		unknown = SortedVertexArray.new
		unknown << Vertex.new(self, 0)
		a = b = weight = neighbour = min = nil
		until unknown.empty?
			min = unknown.shift
			p [min.distance, unknown.size, known.size] if $DEBUG
			known[min.object] = min
			yield min, known
			min.object.each_neighbour do |neighbour, weight|
				weight = 1 unless weight
				unless known.has_key?(neighbour)
                    #p "#{min.object} has neighbour #{neighbour}" if $DEBUG
					unknown << Vertex.new(neighbour, min.distance+ weight, min)
				end
			end
		end
		return known
	end    
end

