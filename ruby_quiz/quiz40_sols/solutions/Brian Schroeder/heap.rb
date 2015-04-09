#!/usr/bin/ruby

class Numeric
  def log2
    Math::log(self) / Math::log(2)
  end

  def even?
    self % 2 == 0
  end

  def odd?
    not even
  end
end

# James Heap Implementation
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

  def to_s(  )
    # We have log_2(n) levels
    #
    # Level i includes at most 2**i nodes when indexed starting from zero
    # That means last level needs the space for at most (2**(ceil(log_2(n)))) 
    #
    # Basic implementation: Reserve the space and fill it

    # Some constants for the ascii art
    short_arm_left = '/'
    short_arm_right = '\\'
    
    arm_left_start = "'"
    arm_left_end = "."
    
    arm_right_start = "`"
    arm_right_end = "."

    arm_line = '-'
    
    join_string = ' '

    # Constants for position calculation
    levels = size.log2.ceil

    max_node_width = @heap[1..-1].map{ | node | node.to_s.length }.max
    max_line_width = 2**(levels-1) * max_node_width + (2**(levels-1)-1) * join_string.length

    (0...levels).inject([]) { | result, level |
      level_node_width = max_line_width / 2**level

      # Draw the arms leading to the nodes on this level
      if level > 0
	result <<
	Array.new(2**level) { | j |
	  if @heap[2**level+j]          # Only draw an arm, if there is a node
	    if level_node_width < 5 # Draw short arm for short distances
	      (j.even? ? short_arm_left : short_arm_right).center(level_node_width)
	    else                    # Draw long arm for long distances
	      if j.even?
		(arm_left_end    + arm_line * (level_node_width / 2 - 1) + arm_left_start).rjust(level_node_width)
	      else
		(arm_right_start + arm_line * (level_node_width / 2 - 1) + arm_right_end ).ljust(level_node_width)
	      end
	    end
	  else
	    ' ' * level_node_width
	  end
	}.join(join_string)#.center(max_line_width)
      end

      # Draw the node on this level
      result << @heap[2**level...2**(level+1)].map { | node | node.to_s.center(level_node_width) }.join(join_string)#.center(max_line_width) 
    }.join("\n")
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
puts "", "Start"
puts priority_queue

priority_queue.insert(13)
puts "", "Insert 13"
puts priority_queue

priority_queue.extract
puts "", "Pop minimum"
puts priority_queue

priority_queue = Heap.new
35.times do
  priority_queue.insert(rand(100)+10000)
end
puts "", "Random inserts"
puts priority_queue

priority_queue = Heap.new
priority_queue.insert(*%w(this are some random words to test the heap on another kind of data))

puts "", "Word heap"
puts priority_queue
__END__
