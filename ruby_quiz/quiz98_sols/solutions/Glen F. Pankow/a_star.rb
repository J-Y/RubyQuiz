#! /usr/bin/env ruby
#
# quiz-98  --  demonstrate the A* search algorithm on a simple map.
#
# Glen Pankow       10/15/06        1.1     Original version.
#
# Licensed under the Ruby License.
#


class Array

    #
    # array.ordered_insert(obj)  -> array
    #
    # We assume the objects in the current array are sorted (based on the
    # objects' <=> method).  Add the object <obj> to the array, keeping it
    # sorted, using a simplistic binary sort method.
    #
    # If <obj> already exists in the array (as understood by <=>), it is still
    # added, but its relation (order-wise) to the already-existing one is not
    # predictable.
    #
    def ordered_insert(obj)
        min_i = 0  ;  max_i = size - 1
        loop do
            return insert(min_i, obj) if (min_i > max_i)
            i = (max_i - min_i) / 2 + min_i
# print "min_i = #{min_i}, max_i = #{max_i}, i = #{i}\n"
            if ((cmp = (obj <=> at(i))) == 0)
                return insert(i, obj)
            elsif (cmp < 0)
                max_i = i - 1
            else    # (cmp > 0)
                min_i = i + 1
            end
        end
    end
end


#
# a_star(graph)
#
# The graph object <graph> is a collection of interconnected nodes with start
# and goal nodes where movement between nodes are weighted by costs.  Apply
# the A* algorithm to this graph.  If a path from the start to the goal node
# is found, an array of the nodes of this path is returned, otherwise nil is
# returned.
#
# A graph object is assumed to support these methods:
#
#     start_node  --  return its starting node.
#
#     goal_node  --  return its goal node.
#
# Each node object in the graph is assumed to support these methods:
#
#    step_cost  --  return the cost (as a Number) of moving into this node from
#       a neighbor node.  If this cost is negative, this step is forbidden.
#
#    path_cost  --  return the cost of the path needed to step to this node
#       (from the start node).
#    path_cost=  --  set this value.  We assume that the start node of the
#       graph has already had its value set to an appropriate initial value.
#
#    distance_cost(goal_node)  --  return the distance cost heuristic between
#       this node and the goal node.
#
#    exp_cost=  --  set the expected total heuristic cost (path_cost +
#       distance_cost) for the node.
#    <=>(other)  --  cost comparison function between nodes based on the
#       expected total heuristic cost value.  Smaller cost values should sort
#       before higher ones.
#
#    successors  --  return an Array of nodes this node may move to.  This
#       method need not filter out nodes already processed; we keep track of
#       that.
#
#    prev_node  --  return the node from which this mode moved to.
#    prev_node=  --  set this node.
#
def a_star(graph)
    queue = [ graph.start_node ]
    closed = { graph.start_node => true }
    while (!queue.empty?)
        if ((node = queue.shift) == graph.goal_node)    # success!
puts "!!!! total cost = #{node.path_cost} !!!!"
            path_nodes = [ ]
            node = graph.goal_node
            while (node != graph.start_node)
                path_nodes.unshift(node)
                node = node.prev_node
            end
            return path_nodes.unshift(graph.start_node)
        end
        node.successors.each do |successor|
            next if (successor.step_cost < 0)       # don't go there!
            path_cost = node.path_cost + successor.step_cost
            if (closed.has_key?(successor))         # already processed?
                next unless (path_cost < successor.path_cost)   # a better path?
                # keep original successor.prev_node
            else                                    # haven't seen yet
                successor.prev_node = node
                closed[successor] = true
            end
            successor.path_cost = path_cost
            successor.exp_cost \
              = path_cost + successor.distance_cost(graph.goal_node)
            queue.ordered_insert(successor)
        end
    end
    nil
end


class Tile

    attr_reader     :row, :col
    attr_accessor   :surface, :prev_tile, :path_cost, :exp_cost
    alias :prev_node  :prev_tile        # method name expected by a_star()
    alias :prev_node= :prev_tile=       # method name expected by a_star()

    def initialize(map, row, col, surface)
        @map, @row, @col, @surface, @prev_tile, @path_cost, @exp_cost \
          = map, row, col, surface, nil, nil, nil
    end

    def start?  ;  @surface == '@' ;  end
    def goal?   ;  @surface == 'X' ;  end

    def surface_cost
        case @surface
        when '.', '@', 'X':  1
        when '*':            2
        when '^':            3
        else                -1      # includes '~'
        end
    end
    alias :step_cost :surface_cost      # method name expected by a_star()

    def distance_cost(other)
        (other.row - @row).abs + (other.col - @col).abs
    end

    def neighbors
        @map.neighbors(self)
    end
    alias :successors :neighbors        # method name expected by a_star()

    def <=>(other)
        # return @path_cost <=> other.path_cost if (@exp_cost == other.exp_cost)
        return @exp_cost <=> other.exp_cost
    end

    def to_s
        "tiles[#{@row}][#{@col}]: '#{@surface}'"
    end
end


class Map

    attr_reader :start_tile, :goal_tile, :tiles
    alias :start_node :start_tile       # method name expected by a_star()
    alias :goal_node  :goal_tile        # method name expected by a_star()

    def initialize(map_file)
        @start_tile, @goal_tile, @tiles = nil, nil, [ ]
        File.open(ARGV[0]) do |io|
            row = 0
            io.each do |line|
                col = 0
                line.chomp.split(//).each do |char|
                    tile = Tile.new(self, row, col, char)
                    if (col == 0)
                        tiles << [ tile ]
                    else
                        tiles[row] << tile
                    end
                    @start_tile = tile if (tile.start?)
                    @goal_tile = tile if (tile.goal?)
                    col += 1
                end
            row += 1
            end
        end
        raise Exception, "No start tile found!\n" if (@start_tile.nil?)
        raise Exception, "No goal tile found!\n" if (@goal_tile.nil?)
        @start_tile.path_cost = 0
    end

    def neighbors(tile)
        neighbors = [ ]
        (-1..1).each do |i|
            row = tile.row + i
            next if ((row < 0) || @tiles[row].nil?)             # off the map!
            (-1..1).each do |j|
                next if ((i == 0) && (j == 0))                  # going nowhere!
                col = tile.col + j
                next if ((col < 0) || @tiles[row][col].nil?)    # off the map!
                neighbors << @tiles[row][col]
            end
        end
        neighbors
    end

    def dump
        (0...@tiles.size).each do |row|
            (0...@tiles[row].size).each do |col|
                print @tiles[row][col].surface
            end
            print "\n"
        end
    end
end


#
# Go for it!
#
fail ArgumentError, "Usage: #{$0} <map_file>\n" \
  unless ((ARGV.size > 0) && File.file?(ARGV[0]))
map = Map.new(ARGV[0])
fail Exception, "!!! no solution !!!\n" \
  if ((path_tiles = a_star(map)).nil?)
path_tiles.each { |tile| tile.surface = '#' }   # plot path (destructively!)
map.dump


__END__

#
# Test Array#ordered_insert.
#
a = [ ]
q = [ ]
1.upto(100) do
    num = rand(20)
    a << num
    q.ordered_insert(num)
    print "after adding #{num}:  #{q.inspect}  "
    if (q == a.sort)
        print "good!\n"
    else
        print "*** BAD ***\n"
    end
end
