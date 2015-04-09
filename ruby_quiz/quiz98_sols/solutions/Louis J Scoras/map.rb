##############################################################################
# map.rb - Contains the code for the mapping part of the program

class Node
 attr_reader :x, :y, :cost

 def initialize(x,y,cost,map)
   @x, @y, @cost, @map = x, y, cost, map
 end

 # Look ma! No nested loops.  cartesian_product lets you generate the
 # offsets then we can just hack away at it with maps/filters until we get
 # the right nodes.
 #
 def neighbors
  h, w = @map.height, @map.width
  offsets = [-1,0,1].freeze
  cartesian_product(offsets,offsets).
    reject  {|i|       i == [0,0]                          }.
    collect {|dx, dy|  [x + dx, y + dy]                    }.
    reject  {|j,k|     j < 0 || k < 0 || j >= h || k >= w  }.
    collect {|j,k|     @map[j,k]                           }.
    select  {|n|       n.cost                              }.
    to_enum
 end

 def distance(node)
   [(x-node.x).abs,(y-node.y).abs].max
 end

 def to_s
   "(#{x},#{y}){#{cost}}"
 end
end

class Map
 TERRAIN_COST = {
     '@' => :start, 'X' => :goal,
     '.' => 1, '*' => 2, '^' => 3
 }.freeze

 attr_reader :width, :height

 def initialize(map_string)
   parse_from_string map_string
 end

 def [](x,y)
   @map[x+y*width]
 end

 def start
   self[*@start]
 end

 def goal
   self[*@goal]
 end

 private

 def parse_from_string(s)
   map = s.split(/\s+/).collect{ |l|
     l.scan(/./).collect {|t|
       TERRAIN_COST[t]
     }
   }

   @height = map.size
   @width  = map[0].size
   @points = cartesian_product((0..width-1),(0..height-1))
   @map    = []

   find_ends(map)

   @points.each do |x,y|
     @map << Node.new(x,y,map[y][x],self)
   end
 end

 def find_ends(map)
   @points.each do |x,y|
     case map[y][x]
       when :start
         @start    = [x,y]
         map[y][x] = 0
       when :goal
         @goal     = [x,y]
         map[y][x] = 0
     end
   end
 end
end
