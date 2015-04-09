#
# A helper class to generate the fibonacci sequence
#
# To get the ith fibonacci number simply call Fibonacci[i]
# You can also get a range with Fibonacci[start..finish]
# So, Fibonacci[0..10] = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
#
# The class calculates only those numbers it needs, at caches them for
# future retrieval.
#
class Fibonacci
  @@series = [1,1]
  @@len = 2

  def self.[](i)
    val = i

    i = val.max if i.class == Range
    if i >= @@len
      (i - @@len + 1).times { |j|
        @@series << @@series[-1] + @@series[-2]
      }
      @@len = i + 1
    end

    @@series[val]
  end
end

#
# A class to animate the fibonacci sequence
class FibonacciAnimator

  # Fetch our series and set up an empty array to draw on
  #
  # Note that due to the lack of 0 width lines in ascii art, 
  # we transform x -> mx+1 (where m is a scaling factor)
  def initialize(num_steps = 6, scale = 2)
    @num_steps = num_steps.to_i
    @scale = scale.to_i
    @series = Fibonacci[0..(@num_steps-1)].collect{ |x| x*@scale + 1 } 

    @graph = []
    @height = @series[-1]
    @width = @height + (@series[-2] || 0)
    @height.times do |row|
      @graph << Array.new(@width).fill(" ")
    end
  end

  # Calculate the top right location for each square
  def build_steps
    row = col = 0 
    dir = -1

    prev = 0
    @steps = []

    # since we don't know where the smallest square should start, we reverse
    # and calculate from large to small
    @series.reverse.each do |size|
      case(dir)
      when 0
        col += prev - 1
      when 1
        row += prev - 1
        col += prev - size
      when 2
        row += prev - size
        col -= size - 1
      when 3
        row -= size - 1
      end

      @steps << [size, row, col]

      prev = size
      dir += 1
      dir %= 4
    end

    # flip our steps so they run from small to large
    @steps.reverse!

    @built = true
  end

  # actually draw (or animate) the fibonacci representation
  # for animation, fps == frames per second
  def draw(animate = false, fps = 2)
    build_steps unless @built
    @steps.each do |step|
      draw_square(*step)
      if animate
        print "\033c" # clear the screen
        puts self
        sleep(1.0 / fps)
      end
    end

    puts self unless animate
  end

  # draw a size x size square with its top left corner at row, col
  def draw_square(size, row, col)
    raise "Cannot draw outside graph bounds." if row < 0 or col < 0 or row >= @height or col >= @width or row + size > @height or col + size > @width

    size.times do |i| 
      hor = "-"
      vert = "|"
      hor = vert = "+" if i == 0 or i + 1 == size

      [[row, col + i], [row + size - 1, col + i]].each do |coord|
        x, y = coord
        @graph[x][y] = hor unless @graph[x][y] == "+"
      end

      [[row + i, col], [row + i, col + size - 1]].each do |coord|
        x, y = coord
        @graph[x][y] = vert unless @graph[x][y] == "+"
      end
    end
  end

  def to_s
    @graph.collect{ |row| row.join("") }.join("\n")
  end
end

fp = FibonacciAnimator.new(*ARGV)
fp.draw(true)
