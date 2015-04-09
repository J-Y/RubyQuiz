#!/bin/ruby
class Mapsolver
TERRAINS = { /[.X@]/ => '1',
             /\*/ => '2',
             /\^/ => '3',
             /\~/ => '0'
}
#FILENAME = 'map.txt'
FILENAME = 'big_map.txt'
  attr_accessor :start_point, :end_point, :path, :costs, :rows
  def initialize(rows, p_start, p_end)
    self.rows = rows
    self.start_point = p_start
    self.end_point = p_end
    @path = [start_point]
    self.costs = rows.map {|row| row.map {|point| 0}}
    #puts @costs.inspect
  end
  #loads the map from the file
  def self.load
    rows = []
    File.open(FILENAME, 'r') do |file|
      p_start = []
      p_end = []
      file.each_line do |line|
        if x = line =~ /@.*/ : p_start = [x, rows.size] end
        if x = line =~ /X.*/ : p_end = [x, rows.size] end
        line = TERRAINS.inject(line.chop) {|l, t| l.gsub(t[0], t[1])}
        row = []
        (0..(line.size - 1)).each {|n| row << line[n].chr.to_i}
        rows.push row
      end
      #puts rows.inspect
      el = Mapsolver.new(rows, p_start, p_end)
      return el
    end
  end
  #the size of the map
  def size
    [@rows[0].size, @rows.size]
  end
  #coords maximum limits
  def limits
    size.map {|s| s -1}
  end
  #neighbords of a given point that are walkable (non 0)
  def neighbords(coords)
    x_min = [0, coords[0] - 1].max
    y_min = [0, coords[1] - 1].max
    x_max = [limits[0], coords[0] + 1].min
    y_max = [limits[1], coords[1] + 1].min
    neighb = []
    (x_min..x_max).each{|x| (y_min..y_max).each {|y| neighb << [x, y] if (!path.member?([x,y]) && !(point_value([x,y]) == 0)) }}
    neighb
  end
  #the distance between two points
  #I multiply * 2 to avoid noisy behaviuor when approaching the end_point
  def distance(point1, point2)
    (point1.zip(point2).map {|c| (c[0] - c[1]).abs}).max*2
  end
  #the cost of the given point (type of terrain)
  def point_value(point)
    @rows[point[1]][point[0]]
  end
  #total score of a point, cached in costs matrix, in case we have to walk back
  #because of a dead end
  def cost(point)
    if (cached_cost = @costs[point[1]][point[0]]) != 0
      return cached_cost
    else
      @costs[point[1]][point[0]] = distance(point, end_point) + point_value(point)
    end
  end
  #marks as non walkable the current point and go back one step on the path
  def bounce
    if @path.size == 1
      print_solution
      raise "Solution panic!!!!"
    end
    @rows[path.last[1]][path.last[0]] = 0
    @path.pop
  end
  #choose and do the move
  def move
    possible_moves = neighbords(path.last)
    return nil if possible_moves.member? end_point
    return bounce if (possible_moves.size == 0)
    possible_moves_costs = possible_moves.map {|m| cost m}
    path << possible_moves[possible_moves_costs.index(possible_moves_costs.min)]
  end
  def solve
    while true
      break unless move
    end
    print_solution
  end
  def print_solution
    line_n = 0
    File.open(FILENAME, 'r') do |file|
      file.each_line do |line|
        out = ''
        (0..(line.size - 1)).each {|n| path.member?([n, line_n])? out << "#" : out << line[n].chr}
        puts out
        line_n += 1
      end
    end
    total_cost = path.inject(0) {|sum, point| sum + cost(point)}
    puts "total cost: #{total_cost}"
  end
end

a = Mapsolver.load
a.solve