#!/usr/local/bin/ruby -w

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
	
	def to_s( )
	  return "[empty heap]" if @heap.size <= 1
	  result = ''
	  root = 1

	  if has_right?(root)
	    print_node(result, ' ', true, right_index(root))
	    result << " |\n"
	  end

	  result << "-o #{@heap[root]}\n"

	  if has_left?(root)
	    result << " |\n"
	    print_node(result, ' ', false, left_index(root))
	  end

	  result
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

	def left_index( index )  ; index * 2     ; end
	def right_index( index ) ; index * 2 + 1 ; end
	def has_left?( index )  ; left_index(index)  < @heap.size ; end
	def has_right?( index ) ; right_index(index) < @heap.size ; end

	def print_node( result, line, right, index )
	  if has_right?(index)
	    print_node(result, line + (right ? '  ' : '| '), true, right_index(index)) 
	    result << "#{line}#{right ? ' ' : '|'} |\n"
	  end

	  result << "#{line}+-o #{@heap[index]}\n"

	  if has_left?(index)
	    result << "#{line}#{right ? '|' : ' '} |\n"
	    print_node(result, line + (right ? '| ' : '  '), false, left_index(index))
	  end
	end
	
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
