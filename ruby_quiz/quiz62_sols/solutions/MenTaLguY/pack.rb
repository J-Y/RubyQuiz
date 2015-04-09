#!/usr/bin/ruby

MAX_SOLUTIONS = 100

class Array
  def pass( &block )
    map( &block ).inject( [] ) { |a, b| a.concat b }
  end
  def minimize
    minimum = map { |x| yield x }.min
    reject { |x| yield( x ) > minimum }
  end
end

module Area
  def area
    @area ||= width * height
  end
  def fits?( space )
    space.width >= width && space.height >= height
  end
end

class Box
  include Area

  attr_reader :min_x, :min_y, :max_x, :max_y

  def initialize( min_x, min_y, max_x, max_y )
    @min_x, @min_y, @max_x, @max_y = min_x, min_y, max_x, max_y
  end

  def intersects?( box )
    box.min_x < @max_x && box.min_y < @max_y &&
      box.max_x > @min_x && box.max_y > @min_y
  end
  def eliminate( box )
    return [self] unless self.intersects? box
    remaining = []
    remaining << Box.new( @min_x, @min_y, box.min_x, @max_y ) \
      if @min_x < box.min_x
    remaining << Box.new( @min_x, @min_y, @max_x, box.min_y ) \
      if @min_y < box.min_y
    remaining << Box.new( box.max_x, @min_y, @max_x, @max_y ) \
      if box.max_x < @max_x
    remaining << Box.new( @min_x, box.max_y, @max_x, @max_y ) \
      if box.max_y < @max_y
    remaining
  end

  def width
    @width ||= @max_x - @min_x
  end
  def height
    @height ||= @max_y - @min_y
  end
end

class Dimensions
  include Area

  attr_reader :width, :height

  def self.new_from_string( string )
    string =~ /(\d+)x(\d+)/
    self.new( $2.to_i, $1.to_i )
  end

  def initialize( width, height )
    @width, @height = width, height
  end

  def rotate
    @rotated ||= Dimensions.new( @height, @width )
  end
  def pad( n )
    Dimensions.new( @width + n, @height + n )
  end
end

class Trunk
  def self.new_from_area( area )
    self.new( area, [], [ Box.new( 0, 0, area.width, area.height ) ] )
  end

  def initialize( area, contents, remaining )
    @area, @contents, @remaining = area, contents, remaining
  end

  def empty? ; @contents.empty? ; end
  def fragmentation ; @remaining.length ; end

  def cram( thingy )
    @remaining.map { |space|
      next nil unless thingy.fits? space
      box = Box.new( space.min_x,
                     space.min_y,
                     space.min_x + thingy.width,
                     space.min_y + thingy.height )
      Trunk.new( @area, @contents + [box],
                 @remaining.pass { |space| space.eliminate box } )
    }.compact
  end

  def pretty_print
    all = @contents + @remaining
    width = @area.width - 1
    height = @area.height - 1
    aa = ( [ "." * width ] * height ).map { |x| x.dup }
    @contents.each do |box|
      for y in box.min_y...( box.max_y - 1 )
        run_length = box.width - 1
        aa[y][box.min_x, run_length] = "*" * run_length
      end
    end
    aa.each { |line| puts line }
  end
end

def pack_trunk( trunk_area, box_areas )
  box_areas.inject( [[ Trunk.new_from_area( trunk_area ), [] ]] ) do
    |solutions, box|

    solutions.pass { |trunk, leftovers|
      packings = trunk.cram( box ) + trunk.cram( box.rotate )
      if packings.empty?
        raise "One of them boxes is too big!" if trunk.empty?
        [[ trunk, leftovers + [box] ]]
      else
        packings.map { |packing| [ packing, leftovers ] }
      end
    }.minimize {
      |trunk, leftovers| leftovers.length
    }.minimize {
      |trunk, leftovers| trunk.fragmentation
    }[0, MAX_SOLUTIONS]
  end
end

def pack_trunks( trunks, trunk_area, box_areas )
  return [trunks] if box_areas.empty?

  pack_trunk( trunk_area, box_areas ).minimize {
    |trunk, leftovers| leftovers.length
  }.pass { |trunk, leftovers|
    pack_trunks( trunks + [trunk], trunk_area, leftovers )
  }
end

def solve( trunk_area, box_areas )
  box_areas = box_areas.sort_by { |box| box.area }.reverse
  pack_trunks( [], trunk_area, box_areas ).minimize {
    |trunks| trunks.length
  }.first
end

trunk_area = Dimensions.new_from_string( gets ).pad( 1 )
box_areas = gets.split.map { |s|
  Dimensions.new_from_string( s ).pad( 1 )
}
solve( trunk_area, box_areas ).each do |trunk|
  puts
  trunk.pretty_print
end
