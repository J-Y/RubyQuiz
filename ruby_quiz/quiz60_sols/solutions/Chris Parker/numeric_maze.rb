require 'benchmark'

class Integer
  def odd?
    return self % 2 == 1
  end

  def even?
    return !odd?
  end
end

#Aliases for more quene like syntax
class Array

  alias deq shift

  alias enq <<

end

#Node class that knows both its children and parent
#Also, takes an intial value and a function to perform on that value
#When retrieving value from a node, the action is performed on the value the first time
#All subsequent calls to value returns the return value of the first time action was called with value
class Node
  attr_reader :action, :children, :parent

  def initialize(value, action, parent=nil)
    @value = value
    @action = action
    @children = []
    @parent = parent
    @done_action = false
  end

  #find the path to the root node from the current node
  def get_path_to_root
    if(parent == nil)
      return [value]
    end
    parent.get_path_to_root<<value
  end

  def tree_size
  #remember that if there are no children, aka this is a leaf node, this returns 1, the initial value of result
    return children.inject(1){|result,child| result + child.tree_size }
  end

  def value
    if(!@done_action)
      @done_action = true
      return @value = @action.call(@value)
    end
    return @value
  end

  #print tree in a stringified array format
  def tree_as_array
    print "%d" % value
    print "[" if children.length != 0
    children.each_with_index{|child, index| child.tree_as_array; print ", " if index != children.length - 1}
    print "]" if children.length != 0
  end

end

#Solves the numeric maze with a bunch of optimizations
#Optimizations:
#(1) if parent action was halve, no child should be double
#(2) if parent action was double, no child should halve
#(3) if value of current node is greater than 3 times the max(start_num, end_num), don't double or add 2
#(4) if value of current node has already been found, stop processing this node
#(5) start_num should always be >= end_num.  This is an optimization because of (3).
#    It kills many branches early, reducing the number of nodes in the tree.  This is done
#    without breaking anything by making add_two be subtract_two and
the results be reversed if start and end are switched.
def solve_maze(start_num, end_num)
  reverse_solution = start_num < end_num
  if reverse_solution
    add_two = lambda{ |int| int-2 }
    start_num,end_num = end_num,start_num
  else
    add_two = lambda{ |int| int+2 }
  end
  double = lambda{ |int| int*2 }
  halve = lambda{ |int| int/2 }
  no_action = lambda{ |int| int } #special case for the start number
  root = Node.new(start_num, no_action)
  #keep track of numbers found to prevent repeat work
  hash = {}
  #the queue for the BFS
  q = [root]
  #start_num is always larger than end_num, numbers larger than this are unlikely to be in
  #an optimal solution
  big_val = start_num*3
  while q.length != 0
    node = q.deq
    val = node.value
    if val == end_num
      solution = node.get_path_to_root
      solution.reverse! if reverse_solution
      return [solution, root.tree_size()]
    end
    if !hash.has_key?(val)
      node.children << Node.new(val, add_two, node) if val.abs < big_val
      node.children << Node.new(val,double,node) if node.action != halve && val.abs < big_val
      node.children << Node.new(val,halve,node) if val.even? && node.action != double
      node.children.each{|kid| q.enq(kid)}
      hash[val] = true
    end
  end
end

if ARGV.length.odd? && !ARGV.length.zero?
  print "Should be an even number of arguments in the format of start_num end_num [start_num end_num] ...\n"
  exit
end

puts Benchmark.measure{
ARGV.each_index do |index|
  if index.odd?
    next
  else
    start_num = ARGV[index].to_i
    end_num = ARGV[index + 1].to_i
    result = solve_maze(start_num, end_num)
    print "solve_maze(",start_num, ", ",end_num,") = ",result[0].inspect,
          "\nLength: ",result[0].length,
          "\nTree size: ",result[1],"\n"
  end
end
}
