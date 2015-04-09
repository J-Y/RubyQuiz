#
# requires the implementation of an each_neighbour method which must yield the neighbours of an object, and optionally the 'cost' of the link.
# it doesn't require the full object list - it builds the list as it goes. Would probably be faster if it had the whole list, but I wanted to keep the
# code generic
#
module Dijkstra
	class Vertex
		attr_reader :object
		attr_accessor :distance
		def initialize(object, distance=nil)
			@object = object
			@distance = distance
		end
		def <=>(other)
			a,b = distance, other.distance
			return 0 unless a || b
			return -1 unless a
			return 1 unless b
			return a <=> b
		end
	end
	# returns a hash where the keys are all reachable nodes and the values are the shortest distances to those nodes
	# yields each node and the calculated distance hash as they are calculated
	def find_distances()
		known = Hash.new
		unknown = Hash.new { |h,k| h[k] = Vertex.new(k)}
		unknown[self] = Vertex.new(self, 0)
		a = b = weight = neighbour = min = nil
		until unknown.empty?
			min = unknown.values.min
			known[min.object] = min
			yield min, known
			min.object.each_neighbour do |neighbour, weight|
				weight = 1 unless weight
				unless known.has_key?(neighbour)
					nd = unknown[neighbour]
					nd.distance = [nd.distance, min.distance+ weight].min
				end
			end
			unknown.delete(min.object)
		end
		return distances
	end
	# finds the shortest path from the current node to the specified end_node
	def shortest_path(end_node)
		find_distances() do |found_vertex, known_vertexes|
			if(found_vertex.object == end_node)
				return shortest_path_internal(found_vertex, known_vertexes)
			end
		end
		return nil
	end
	private
	def shortest_path_internal(end_vertex, known_vertexes)
		path = [end_vertex]
		until path[0].object == self
			closest = min_distance = nil
			path[0].object.each_neighbour  do |neighbour, weight|
				weight ||= 1
				if known_vertexes[neighbour]
					vertex = known_vertexes[neighbour]
					distance = vertex.distance + weight
					if min_distance.nil? || distance < min_distance
						closest = vertex
						min_distance = distance
					end
				end
			end
			path = [closest] + path
		end
		return path.collect {|x| x.object }
	end
end

class Word
	include Dijkstra

	@@similar = Hash.new {|h,k| h[k] = Array.new}

	def initialize(string)
		@string = Word.normalize(string)
		@similar_keys = []
		@string.length.times do |i|
			@similar_keys[i] = String.new(@string)
			@similar_keys[i][i] = "."
		end
		#allow changing word lengths - for some reason this makes it FASTER for the same-length scenario??
		@similar_keys << @string[0..-2]  if @string.length > 1
		@similar_keys << @string
		@similar_keys << @string + "."
		# ---
		@similar_keys.each do |key| 
			words = @@similar[key]
			words << self
		end
	end	
	def each_neighbour(&block)
		@nieghbours = @similar_keys.each do |key|
			@@similar[key].each {|word| yield word }
		end
	end
	def Word.read_words(word_file, size_range=nil)
		Dir[word_file].each do |filename|
			warn "reading #{filename}" if $DEBUG
			File.open(filename) do |f|
				f.each do |x|
					x = normalize(x)
					Word.new(x) if size_range.nil? || size_range.include?(x.size)
				end
			end	
		end
	end
	def <=>(other)
		@string <=> other.to_s
	end
	def to_s
		@string
	end
	private
	def Word.normalize(string)
		string = string.downcase
		string.strip!
		string.gsub!(/[^a-z]/,"")
		string
	end
end

if $0 == __FILE__
	start_word = ARGV[0] || "duck"
	end_word = ARGV[1] || "ruby"
	dictionary = ARGV[2] || "scowl/final/english-words.[0-3]*"
	Word.read_words(dictionary, Range.new(*[start_word.length, end_word.length].sort))	
	start_node = Word.new(start_word)
	end_node = Word.new(end_word)
	shortest_path = start_node.shortest_path(end_node)
	puts shortest_path
end
