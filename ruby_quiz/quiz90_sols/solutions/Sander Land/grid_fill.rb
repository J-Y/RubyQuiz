
module Enumerable
  def x(enum)  # Cartesian product
    map{|a| enum.map{|b| [a,b].flatten }}.inject([]) {|a,b| a+b}
  end
  def **(n) #  Cartesian power
    if n == 1
      self
    else
      self.x(self**(n-1))
    end
  end
end

module OpenStructable
  def method_missing(method,*args)
    (class<<self;self;end).send(:attr_accessor, method.to_s.sub('=','') )
    send(method,*args)
  end
end
  
class Vertex < Array
  include OpenStructable
  def initialize(name)
    self.name = name
  end
end

class Graph
  def initialize
    @vertices = Hash.new{|h,k| h[k] = Vertex.new(k) }
  end
  
  def add_edge(from,to)
    @vertices[from] << @vertices[to]
  end
  
  def warnsdorff_tour(start)
    @vertices.each_value{|v|
      v.score = v.size
      v.done = false
    }
    curr_node = @vertices[start]
    tour = []
    while curr_node
      tour << curr_node
      curr_node.done = true
      curr_node.each{|v| v.score -= 1}
      curr_node = curr_node.reject{|v| v.done}.sort_by{|v| v.score}.first
    end
    tour.map{|t| t.name}
  end

end

n = (ARGV[0] || 5).to_i
graph = Graph.new

dirs = [2,-2]**2 + [[0,3],[3,0],[0,-3],[-3,0]]

valid = 0...n

(valid**2).each {|x,y|
  dirs.each{|dx,dy|
    to_x, to_y =  x + dx, y + dy
    graph.add_edge([x,y] , [to_x,to_y]) if valid.include?(to_x) && valid.include?(to_y)
  }
}
grid = Array.new(n){Array.new(n)}

# This shows how long a tour starting from each square is
if ARGV[1]
  full_count = 0
  (valid**2).each{|x,y| 
    grid[y][x] =  graph.warnsdorff_tour([x,y]).length
    full_count += 1 if grid[y][x] == n*n
  }
  puts "#{full_count} / #{n*n} = #{'%.2f' % [100*full_count.to_f/(n*n)]} % of the possible starting positions give a full tour."
else

solution = []
try = 0
([0,n-1]**2 + [0].x(1..n-2) + (1..n-2)**2).each{|sx,sy|  # for starting square, try corners first, then one edge, then inside
  try += 1
  solution = graph.warnsdorff_tour([sx,sy])
  break if solution.length == n*n
}

if solution.length != n*n
  puts "Failed to find tour." 
  exit!
end
puts "Found tour in #{try} tries."

solution.each_with_index{|(x,y),i| grid[y][x] = i+1 }
end

max_len = (n * n).to_s.length

sep = ('+' + '-' * (max_len+2) ) * n + '+'
puts sep, grid.map{|row| '| ' + row.map{|n| n.to_s.center(max_len) }.join(' | ') + ' |' }.join("\n" + sep + "\n"), sep