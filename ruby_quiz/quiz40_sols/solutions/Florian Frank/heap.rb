#!/usr/local/bin/ruby -w

class Heap
	class HeapVisualizer
	  def initialize(heap)
	    @heap = heap.instance_variable_get(:@heap)[1..-1]
	  end

	  def to_s
	    @curved = [ ]
	    recurse
	  end

	  private

	  def recurse(node = 0, level = 0)
	    result = ''
	    return result unless @heap[node]
	    for l in 0 ... level
	      result << if @curved[l]
	        l == level - 1 ? '`---' : ' ' * 4
	      else
	        l == level - 1 ? '+---' : '|   '
	      end
	    end
	    result << "#{@heap[node]}\n"
	    left, right = (node << 1) + 1, (node << 1) + 2
	    if @heap[left]
	      @curved[level] = @heap[right] ? false : true
	      result << recurse(left, level + 1)
	      if @heap[right]
	        @curved[level] = true
	        result << recurse(right, level + 1)
	      end
	    end
	    result
	  end
	end

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
	
	def to_s(  )
	  HeapVisualizer.new(self).to_s
	end
	
	def validate(  )
		1.upto(@heap.size - 1) do |i|
			c = 2 * i
			break if c >= @heap.size
			return false unless @heap[i] <= @heap[c]
			
			c += 1
			break if c >= @heap.size
			return false unless @heap[i] <= @heap[c]
		end
		
		true
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

priority_queue = Heap.new
priority_queue.insert(12, 20, 15, 29, 23, 17, 22, 35, 40, 26, 51, 19)
puts priority_queue

priority_queue.insert(13)
puts priority_queue

priority_queue.extract
puts priority_queue
