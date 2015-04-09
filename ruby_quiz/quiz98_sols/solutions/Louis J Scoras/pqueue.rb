##############################################################################
# pqueue.rb - a max/min heap implementation of a priority queue

# By having the constructor take the comparison function, this makes
# using it for A* extremely easy

class PQueue
 def initialize(&sorter)
   @data = []
   @sorter = sorter ||
     lambda do |a,b|
       a <=> b
     end
 end

 def inspect
   @data.sort(&@sorter).reverse.inspect
 end

 def <<(element)
   @data << element
   bubble_up
   self
 end

 def size
   @data.size
 end

 alias_method :enqueue, :<<

 def dequeue
   if size == 1
     @data.pop
   else
     highest, @data[0] = @data[0], @data.pop
     bubble_down
     highest
   end
 end

 def empty?
   size == 0
 end

 private

 def bubble_up
   current_element = size - 1

   until root?(current_element)
     parent = parent_index(current_element)
     if @sorter[@data[parent], @data[current_element]] <= 0
       swap_nodes(parent, current_element)
     end
     current_element = parent_index(current_element)
   end
 end

 def bubble_down
   current_element = 0

   until leaf?(current_element)
     fc, sc = first_child(current_element), second_child(current_element)
     better = choose(fc,sc)

     if @sorter[@data[current_element], @data[better]] > 0
       break
     else
       swap_nodes(current_element, better)
       current_element = better
     end
   end
 end

 def parent_index(index)
   (index - 1) / 2
 end

 def root?(element)
   element == 0
 end

 def swap_nodes(a,b)
   @data[a], @data[b] = @data[b], @data[a]
 end

 def first_child(index)
   bounds_check(index * 2 + 1)
 end

 def second_child(index)
   fc = first_child(index)
   fc ? bounds_check(fc + 1) : nil
 end

 def bounds_check(index)
   index < size ? index : nil
 end

 def leaf?(index)
   ! first_child(index)
 end

 def choose(a,b)
   if b
     @sorter[@data[a], @data[b]] >= 0 ? a : b
   else
     a
   end
 end
end
