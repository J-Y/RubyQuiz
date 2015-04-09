=begin

  * Program : Solution for Ruby Quiz #33 Tiling Turmoil
  * Author  : David Tran
  * Date    : 2005-05-25
  * Version : Fast, less iteration version

  Here is my other solution.

  Below note is only apply for n >= 3 ( start from 8x8 )
  for n =1 (2x2) and n=2 (4x4) the solution is unique.

  It still has a special case need to solve. 
  (Do not want google to find solution for the special case)

  The small rectangle form by tromino is 2x3 (or 3x2) note as R(2,3).
  Below, it discuss only for 2x3 case. (for 3x2, just rotate it)

  This means all area of 2nx3m can tile by the small rectangle of 2 tromino.

  So, for 2^n x 2^n cases:
  1. If the missing cell is in the central square of 2^(n-1) x 2^(n-1)
     (see graph below, form by 6 + 7 + 10 + 11)
     then the around central square could tile by R(2,3).

     +----+----+----+----+  The big square is 2^n x 2^n
     | 1  |  2 |  3 | 4  |  Each small square is 2^(n-2) x 2^(n-2)
     |    |    |    |    |
     +----+----+----+----+
     | 5  |  6 | 7  | 8  |
     |    |   x|    |    |
     +----+----+----+----+
     | 9  | 10 | 11 | 12 |
     |    |    |    |    |
     +----+----+----+----+
     | 13 | 14 | 15 | 16 |
     |    |    |    |    |
     +----+----+----+----+

     The around central can form by 4 rectangles and can be tile by R(2,3).
     * first-rectangle: 1 + 2 + 3
       start point (0, 0), width = 3 x 2^(n-2), height = 2^(n-2)
       As you can see width is divisible by 3 and height is divisible by 2.
     * second-rectangle: 4 + 8 + 12
     * third-rectangle: 14 + 15 + 16
     * fourth-rectangle: 5 + 9 + 13

     And this reduce the problem downto the central 2^(n-1)x2^(n-1) to solve.

  2. If the missing cell is in one of the corner 2^(n-2)x2^(n-2) then
     the problem is downto solve that corner; out of the corner could tile
     by R(2,3). For example: if the missing cell is on top-left corner.
     Out of that corner is:
     * first-rectangle : form by 2 + 3 + 4
       width = 3 x 2^(n-2), hieght = 2^(n-2), can be tile by R(3,2)
     * second-rectangle : form by 5+6+7+8+ ... + 16
       width = 2^n, height = 3 x 2^(n-2), can be tile by R(2,3)

     +----+----+----+----+
     | 1  |  2 |  3 | 4  |
     |  x |    |    |    |
     +----+----+----+----+
     | 5  |  6 |  7 | 8  |
     |    |    |    |    |
     +----+----+----+----+
     | 9  | 10 | 11 | 12 |
     |    |    |    |    |
     +----+----+----+----+
     | 13 | 14 | 15 | 16 |
     |    |    |    |    |
     +----+----+----+----+

  3. We already see the missing cell on center (6+7+10+11) case.
     Also the missing cell on corner (1, 4, 13 or 16) case.
     Now, let's see if missing cell on the center border square 
     of 2^(n-2)x2^(n-2) ( For example form by half #2 and half #3 )

     +----+----+----+----+
     | 1  | 2! | ! 3| 4  |
     |    |  !x| !  |    |
     +----+----+----+----+
     |__5_|  6 |  7 | 8  |
     |    |    |    |    |
     +----+----+----+----+
     |__ _| 10 | 11 | 12 |
     |  9 |    |    |    |
     +----+----+----+----+
     | 13 | 14 | 15 | 16 |
     |    |    |    |    |
     +----+----+----+----+

     The problem reduce to solve that 2^(n-2)x2^(n-2) square only.
     Outside of that square, it could tile by R(2,3).
     * first-rectangle : 5 + 6 + 7 + ... + 16 could tile by R(2,3)
       this rectangle already discussed on 2. (see above corner case)
     * second-rectangle : 1 + half of 2
       width = 2^(n-2) + (2^(n-2) / 2) = 3 x 2^(n-3) 
       height = 2^(n-2)
       (width is divisible by 3, height is divisible by 2)
     * third-rectangle : half 3 + 4 
       could tile by R(2,3) too, same logic as second rectangle.

  4. The rest of missing cell possible is "special" case,
     For example the missing cell on half left of 2, or half right of 3,
     or half top of 5, or half bottom of 9 ... etc
     By using paper and pencil, I could solve it easily (for 8x8, 16x16), 
     it is try to place a tromino with one case in central square (6+7+10+11),
     and the problem downto solve the central square; and the around the 
     center square is tile by R(2,3).
     Unfortunately, I have not yet come out with a generic logic for it.
     For those special case, I will just back to normal solve-by_inductive
     logic for first iteration.


   Note the code is a little mess, maybe define a rotateFloor method
   to help clean up...

=end

class Floor 

  attr_accessor :width, :height

  def initialize(width, height=width, data=nil)
    @width = width
    @height = height
    @data = data ? data : Array.new(width) { Array.new(height) }
  end

  def [](x, y)
    @data[x][y]
  end

  def []=(x, y, value)
    @data[x][y] = value
  end

  # Maximum tiles needs to cover floor without excess floor
  def number_tiles
    width * height / 3
  end

  def include?(x, y)
    0 <= x && x < width && 0 <= y && y < height
  end

  def tile(missing_x, missing_y, start_tile_number = 1)    
    n = @width
    nb = start_tile_number
    if n <= 4
      tile_by_inductive(missing_x, missing_y, start_tile_number)
      return
    end

    squares = {
      ##### central square case #####
      [n/4, n/4, n/2] => [[0, 0, 3*n/4, n/4], [3*n/4, 0, n/4, 3*n/4],
                          [0, n/4, n/4, 3*n/4],[n/4, 3*n/4, 3*n/4, n/4] ],

      ##### corner square case  #####
      [0, 0, n/4]         => [ [n/4, 0, 3*n/4, n/4], [0, n/4, n, 3*n/4] ],
      [3*n/4, 0, n/4]     => [ [0, 0, 3*n/4, n/4], [0, n/4, n, 3*n/4] ],
      [0, 3*n/4, n/4]     => [ [0, 0, n, 3*n/4], [n/4, 3*n/4, 3*n/4, n/4] ],
      [3*n/4, 3*n/4, n/4] => [ [0, 0, n, 3*n/4], [0, 3*n/4, 3*n/4, n/4] ],

      ##### middle border square case  #####
      [3*n/8, 0, n/4] => [[0,0,3*n/8,n/4], [5*n/8,0, 3*n/8,n/4], [0,
n/4, n, 3*n/4]],
      [0, 3*n/8, n/4] => [[0,0,n/4,3*n/8], [0,5*n/8, n/4, 3*n/8],
[n/4, 0, 3*n/4,n]],
      [3*n/8, 3*n/4, n/4]
=>[[0,3*n/4,3*n/8,n/4],[5*n/8,3*n/4,3*n/8,n/4],[0,0,n,3*n/4]],
      [3*n/4, 3*n/8, n/4] =>[[3*n/4,0,
n/4,3*n/8],[3*n/4,5*n/8,n/4,3*n/8],[0,0,3*n/4,n]]
    }

    squares.each do |(from_x, from_y, size), rectangles|
      x = missing_x - from_x
      y = missing_y - from_y
      floor = subFloor(from_x, from_y, size)
      if floor.include?(x, y)
        rectangles.each do |(from_x, from_y, width, height)|
          rectangle_floor = subFloor(from_x, from_y, width, height)
          rectangle_floor.tile_without_missing(nb)
          nb += rectangle_floor.number_tiles
        end
        floor.tile(x, y, nb)
        return
      end      
    end

    ##### at this point, the missing cell is on the "special cases" #####
    tile_by_inductive(missing_x, missing_y, start_tile_number)
  end

  protected

  def tile_by_inductive(missing_x, missing_y, start_tile_number)
    half_width = width / 2
    half_height = height / 2
    shifts = [ [0, 0], [half_width,0], 
               [0, half_height], [half_width, half_height] ]

    missings = [ [half_width - 1, half_height - 1], [0, half_height - 1],
                 [half_width - 1, 0], [0, 0] ]

    floors = shifts.inject([]) do |floors, (from_x, from_y)|
      floors << subFloor(from_x, from_y, half_width, half_height)
    end

    nb = start_tile_number + 1
    shifts.each_with_index do |(from_x, from_y), i|
      x = missing_x - from_x
      y = missing_y - from_y
      if !floors[i].include?(x, y)
        x = missings[i][0]
        y = missings[i][1]
        floors[i][x,y] = start_tile_number
      end
      if width > 2 && height > 2
        floors[i].tile(x, y, nb) # call normal tile (not tile_by_inductive) !
        nb += floors[i].number_tiles
      end
    end
  end

  def tile_without_missing(start_tile_number)
    nb = start_tile_number - 1
    if (width % 2 == 0 && height % 3 == 0)
      (0...width).step(2) do |x|
        (0...height).step(3) do |y|
          self[x,y] = self[x+1,y] = self[x+1,y+1] = (nb += 1)
          self[x,y+1] = self[x,y+2] = self[x+1,y+2] = (nb += 1)
        end
      end
    elsif (width % 3 == 0 && height % 2 == 0)
      (0...width).step(3) do |x|
        (0...height).step(2) do |y|
          self[x,y] = self[x,y+1] = self[x+1,y] = (nb += 1)
          self[x+1,y+1] = self[x+2,y] = self[x+2,y+1] = (nb += 1)
        end
      end        
    else
      fail "Without missing cell, this can only tile a " +
           "floor area of 2nx3m or 3nx2m rectangle."
    end    
  end

  private 

  def subFloor(from_x, from_y, width, height=width)
    floor = Floor.new(width, height, @data)
    class << floor
      attr_accessor :from_x, :from_y
      alias :old_get :[]
      alias :old_set :[]=

      def [](x, y)
        old_get(@from_x + x, from_y + y)
      end

      def []=(x, y, value)
        old_set(@from_x + x, from_y + y, value)
      end
    end
    floor.from_x = from_x + (respond_to?(:from_x) ? self.from_x : 0)
    floor.from_y = from_y + (respond_to?(:from_y) ? self.from_y : 0)
    floor
  end

end

(puts "Usage: #$0 n"; exit) if ARGV.size <= 0 || ARGV[0].to_i <= 0
n = 2 ** ARGV[0].to_i
floor = Floor.new(n)
missing_x = rand(n)
missing_y = rand(n)
floor[missing_x, missing_y] = 'X'
floor.tile(missing_x, missing_y)
format = "%#{(n*n/3).to_s.size+1}s"
(0...n).each {|y| (0...n).each {|x| print(format % floor[x,y]) }; puts }


=begin
# Simple unit test
n = 16
(0...n).each do |x|
  (0...n).each do |y|
    floor = Floor.new(n, n)
    floor[x,y] = 0
    floor.tile(x, y)
    a = Array.new(n*n/3+1, 0)
    (0...n).each { |i| (0...n).each { |j| a[floor[i,j]] += 1 } }
    a[0] += 2
    a.each { |e| fail "FAIL: missing at #{x}, #{y}" if e != 3 }
    puts "Missing at #{x}, #{y} => OK"
  end
end
=end
