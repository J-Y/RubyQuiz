class Array
  def generate_valid_paths
    next_values = [last+2, last*2]
    next_values << (last / 2) if last%2 == 0
    next_values.map {|value| self + [value]}
  end
end

def solve(start, goal)
  astar(start,goal)
end

require 'rubygems'
require 'priority_queue'

def astar(start,goal)
  open = PriorityQueue.new
  start_cost = 1 + heuristic(start,goal)
  open[[start]] = start_cost
  closed = Hash.new(1.0/0)
  closed[start] = start_cost
  loop do
    path, cost = open.delete_min
    return path if path.last == goal
    path.generate_valid_paths.each do |new_path|
      new_cost = new_path.length + heuristic(new_path.last,goal)
      next if closed[new_path.last] < new_cost
      open[new_path] = new_cost
      closed[new_path.last] = new_cost
    end
  end
end



def heuristic(start,goal)
  if start == 0
    if goal == 0
      return 0
    else
      return 1 + heuristic(2,goal)
    end
  end
  if start == 1
    return [1 + heuristic(3,goal), (log_base(2,start) - log_base(2,goal)).abs].min
  end
  
  (log_base(2,start) - log_base(2,goal)).abs
end

def log_base(base,n)
  Math.log(n)/Math.log(base)
end