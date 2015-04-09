class Problem
  attr_reader :start, :goal

  def initialize
    @data = []
    STDIN.readlines.each do |line|
      @data << line.chomp
      start = line =~ /@/
      @start = [start, @data.length-1] if start != nil
      goal = line =~ /X/
      @goal = [goal, @data.length-1] if goal != nil
    end
  end

  def cost(x,y)
    if x < 0 || x >= @data.length || y < 0 || y >= @data[0].length
      nil
    elsif @data[x][y..y].match(/[@\.X]/)
      1
    elsif @data[x][y..y] == '*'
      2
    elsif @data[x][y..y] == '^'
      3
    else
      nil
    end
  end

  # Returns the list of all the neighbors
  def neighbors node
    neighbors_list = []
    x,y = node
    for i in -1..1 do
      for j in -1..1 do
	if i != 0 || j != 0
	  cost = cost(x+i, y+j)
	  neighbors_list << [[x+i, y+j],cost] unless cost == nil
	end
      end
    end
    neighbors_list
  end

  def heuristic node
    x, y = node
    gx, gy = @goal
    (gx-x)**2 + (gy-y)**2
  end

  def end_node? node; node == @goal; end

  def print_solution path
    data = @data
    path.each{|x,y| data[x][y] = '#'}
    data.each{|line| puts line}
  end
end

class A_star
  attr_reader :closed

  def initialize problem
    @problem = problem
    @open = [problem.start]
    @closed = []
    @f = {problem.start => 0} # Estimated cost
    @g = {problem.start => 0} # Cost so far
  end

  def run
    while @open != []
      node = @open.pop
      @closed << node
      return @closed if @problem.end_node? node

      @problem.neighbors(node).each do |n|
	neighbor, cost = n
	add_to_open(neighbor, @g[node] + cost)
      end
    end
    return nil
  end

  def add_to_open(node, cost)
    unless @closed.include? node
      if @open.include? node
	@g[node] = cost if cost < @g[node]
      else
	@open << node
	@g[node] = cost
      end
      @f[node] = @g[node] + @problem.heuristic(node)
      @open.sort! {|a,b| @f[b] <=> @f[a]}
    end
  end
end

pb = Problem.new
test = A_star.new pb
pb.print_solution test.run
