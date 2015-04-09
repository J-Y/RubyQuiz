# A node represents a tile in the game
class Node
  include Comparable # by total_cost

  class << self
    # each node class is defined by a "map letter" and a cost (1, 2, 3)
    attr_accessor :letter, :cost
  end

  attr_accessor :position, :parent, :cost, :cost_estimated

  def initialize(position)
    @position = position
    @cost = 0
    @cost_estimated = 0
    @on_path = false
    @parent = nil
  end

  def mark_path
    @on_path = true
    @parent.mark_path if @parent
  end

  def walkable?
    true # except Water
  end

  def total_cost
    cost + cost_estimated
  end

  def <=> other
    total_cost <=> other.total_cost
  end

  def == other
    position == other.position
  end

  def to_s
    @on_path ? '#' : self.class.letter
  end
end

class Flatland < Node
  self.letter = '.'
  self.cost   = 1
end

class Start < Flatland
  self.letter = '@'
end

class Goal < Flatland
  self.letter = 'X'
end

class Water < Node
  self.letter = '~'
  def walkable?
    false
  end
end

class Forest < Node
  self.letter = '*'
  self.cost   = 2
end

class Mountain < Node
  self.letter = '^'
  self.cost   = 3
end

NodeClassByLetter = {}
[Flatland, Start, Goal, Water, Forest, Mountain].each do |klass|
  NodeClassByLetter[klass.letter] = klass
end

# An (x, y) position on the map
class Position
  attr_accessor :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def ==(other)
    return false unless Position===other
    @x == other.x and @y == other.y
  end

  # Manhattan
  def distance(other)
    (@x - other.x).abs + (@y - other.y).abs
  end

  # Get a position relative to this
  def relative(xr, yr)
    Position.new(x + xr, y + yr)
  end
end

# A map contains a two-dimensional array of nodes
class Map
  include Enumerable # for find

  def initialize(io)
    @nodes = []
    y = 0
    io.each_line do |line|
      x = 0
      @nodes[y] = []
      line.chomp.split(//).each do |letter|
        @nodes[y] << NodeClassByLetter[letter].new(Position.new(x, y))
        x += 1
      end
      y += 1
      @width  = x
    end
    @height = y
  end

  # Returns true if the given position is on the map
  def contains?(pos)
    pos.x >= 0 and pos.x < @width and pos.y >= 0 and pos.y < @height
  end

  # Return node at position
  def at(pos)
    @nodes[pos.y][pos.x]
  end

  # Iterate all nodes
  def each
    @nodes.each do |row|
      row.each do |node|
        yield(node)
      end
    end
  end

  # Iterates through all adjacent nodes
  def each_neighbour(node)
    pos = node.position
    yield_it = lambda{|p| yield(at(p)) if contains? p} # just a shortcut
    yield_it.call(pos.relative(-1, -1))
    yield_it.call(pos.relative( 0, -1))
    yield_it.call(pos.relative( 1, -1))
    yield_it.call(pos.relative(-1,  0))
    yield_it.call(pos.relative( 1,  0))
    yield_it.call(pos.relative(-1,  1))
    yield_it.call(pos.relative( 0,  1))
    yield_it.call(pos.relative( 1,  1))
  end

  def to_s
    @nodes.collect{|row|
      row.collect{|node| node.to_s}.join('')
    }.join("\n")
  end
end

# see http://www.policyalmanac.org/games/aStarTutorial.htm
class PathFinder
  def find_path(map)
    start = map.find{|node| Start === node}
    goal  = map.find{|node| Goal  === node}
    open_set   = [start] # all nodes that are still worth examining
    closed_set = []      # nodes we have already visited

    loop do
      current = open_set.min # find node with minimum cost
      raise "There is no path from #{start} to #{goal}" unless current
      map.each_neighbour(current) do |node|
        if node == goal # we made it!
          node.parent = current
          node.mark_path
          return
        end
        next unless node.walkable?
        next if closed_set.include? node
        cost = current.cost + node.class.cost
        if open_set.include? node
          if cost < node.cost # but it's cheaper from current node!
            node.parent = current
            node.cost   = cost
          end
        else # we haven't seen this node
          open_set << node
          node.parent = current
          node.cost   = cost
          node.cost_estimated = node.position.distance(goal.position)
        end
      end
      # move "current" from open to closed set:
      closed_set << open_set.delete(current)
    end
  end
end


abort "usage: #$0 <mapfile>" unless ARGV.size == 1
map = Map.new(File.open(ARGV[0]))
finder = PathFinder.new
finder.find_path(map)
puts map
