#!/usr/bin/ruby
#
# Drawing Trees
#
# A response to Ruby Quiz of the Week #40 [ruby-talk:149184]
#
# The Heap implementation is from the quiz question.
#
# The tree drawing algorithm in to_s, and the helper methods empty? and depth
# are mine.
#
# Author: Dave Burt <dave at burt.id.au>
#
# Created: 25 Jul 2005
#
# Last modified: 26 Jul 2005
#
# Fine print: Provided as is. Use at your own risk. Unauthorized copying is
#             not disallowed. Credit's appreciated if you use my code. I'd
#             appreciate seeing any modifications you make to it.

class Heap
	def initialize( *elements, &comp )
		@heap = [nil]
		@comp = comp || lambda { |p, c| p <=> c }
		
		insert(*elements)
	end
	
	def clear(  )
		@heap = [nil]
	end
	
	def extract(  )
		case size
		when 0
			nil
		when 1
			@heap.pop
		else
			extracted = @heap[1]
			@heap[1] = @heap.pop
			sift_down
			extracted
		end
	end
	
	def insert( *elements )
		elements.each do |element|
			@heap << element
			sift_up
		end
	end
	
	def size(  )
		@heap.size - 1
	end
	
	def inspect(  )
		@heap[1..-1].inspect
	end
	
	#
	# Use a right-hand-side depth-first traversal of the tree to draw the right
	# arms above the left arms, with the root at the left and leaves on the
	# right:
	#
	#     1-3
	#      `2
	#
	def to_s(  )
		
		# empty heap -> empty string
		return "" if empty?
		
		d = depth
		
		# w is the width of a column
		w = Array.new(d) do |i|
			@heap[2**i, 2**i].inject(0) {|m, o| [m, o.to_s.size].max }
		end
		
		# ww is the total width of the string (and of each line in it)
		ww = w.inject {|m, o| m + o + 1 } - 1
		
		# done is a flag for the traversal algorithm - it marks indexes in
		# @heap that have already been traversed.
		done = Array.new(2**d)
		done[0] = true
		
		# s is the string that will be returned
		s = ""
		
		# The outer loop counts down the last @heap index for each row. last
		# takes the index of each leaf node, from right to left.
		(2**d - 1).downto(2**(d - 1)) do |last|
			# a accumulates a list of @heap indexes for a row
			a = [last]
			a << (a.last >> 1) until done[a.last >> 1]
			a.each {|x| done[x] = true }
			
			# The inner loop iterates through the columns, from the root to the
			# leaves.
			(d - 1).downto(0) do |col|
				# Append a fixed-width string: a node, a line or spaces
				s << "%#{w[d - col - 1] + 1}s" %
					if a.size > col                       # a node
						@heap[a[col]].to_s + "-"
					elsif last >> col - 1 & 1 == 1        # a line
						"| "
					elsif (last + 1) >> col - 1 & 1 == 1  # an "L" angle
						"`-"
					end
			end
			
			# Replace the trailing "-" after all the leaf nodes with a newline.
			s[-1] = "\n"
		end
		s
	end
	
	def empty?(  )
		size == 0
	end
	
	def depth(  )
		if empty?
			0
		else
			(Math.log(@heap.size - 1) / Math.log(2)).to_i + 1
		end
	end
	
	private
	
	def sift_down(  )
		i = 1
		loop do
			c = 2 * i
			break if c >= @heap.size
			
			c += 1 if c + 1 < @heap.size and @comp[@heap[c + 1], @heap[c]] < 0
			break if @comp[@heap[i], @heap[c]] <= 0
			
			@heap[c], @heap[i] = @heap[i], @heap[c]
			i = c
		end
	end
	
	def sift_up(  )
		i = @heap.size - 1
		until i == 1
			p = i / 2
			break if @comp[@heap[p], @heap[i]] <= 0
			
			@heap[p], @heap[i] = @heap[i], @heap[p]
			i = p
		end
	end
end

if $0 == __FILE__
	priority_queue = Heap.new
	priority_queue.insert(12, 20, 15, 29, 23, 17, 22, 35, 40, 26, 51, 19)
	puts priority_queue
	
	priority_queue.insert(13)
	puts priority_queue
	
	priority_queue.extract
	puts priority_queue
	
	priority_queue.clear
	priority_queue.insert("another", "are", "data", "random", "heap", "of",
		"kind", "this", "the", "words", "on", "to", "some", "test")
	puts priority_queue
end
