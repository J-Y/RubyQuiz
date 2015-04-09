class SimFrost

  # A Cell keeps track of its contents.  It is essentially a mutable
  # Symbol with some extra knowledge to convert into a string.
  class Cell
    attr_accessor :contents

    @@strings = { :space => ' ', :ice => '*', :vapor => '-' }

    def initialize(contents)
      @contents = contents
    end

    def to_s
      @@strings[@contents]
    end
  end  # class SimFrost::Cell


  # A Grid overlays the space dividing it up into 2-by-2 Boxes.
  # Different Grids can cover the same space if the offsets are
  # different.
  class Grid

    # A Box is a 2-by-2 slice of the space containing 4 cells, and a
    # Grid contains a set of Boxes that cover the entire space.
    class Box
      def initialize
        @cells = []
      end

      # Appends a cell to this box
      def <<(cell)
        @cells << cell
      end

      # Adjust the cell contents by the following rules: if any cell
      # contains Ice then all vapor in the Box will be transformed to
      # ice.  Otherwise rotate the four cells clockwise or
      # counter-clockwise with a 50/50 chance.
      def tick
        if @cells.any? { |cell| cell.contents == :ice }
          @cells.each do
            |cell| cell.contents = :ice if cell.contents == :vapor
          end
        else
          if rand(2) == 0  # rotate counter-clockwise
            @cells[0].contents, @cells[1].contents,
              @cells[2].contents, @cells[3].contents =
                @cells[1].contents, @cells[3].contents,
                  @cells[0].contents, @cells[2].contents
          else  # rotate clockwise
            @cells[0].contents, @cells[1].contents,
              @cells[2].contents, @cells[3].contents =
                @cells[2].contents, @cells[0].contents,
                  @cells[3].contents, @cells[1].contents
          end
        end
      end
    end  # class SimFrost::Grid::Box


    # Creates a Grid over the space provided with the given offset.
    # Offset should be either 0 or 1.
    def initialize(space, offset)
      @boxes = []
      rows = space.size
      cols = space[0].size

      # move across the space Box by Box
      (rows / 2).times do |row0|
        (cols / 2).times do |col0|

          # create a Box and add it to the list
          box = Box.new
          @boxes << box

          # add the four neighboring Cells to the Box
          (0..1).each do |row1|
            (0..1).each do |col1|
              # compute the indexes and wrap around at the far edges
              row_index = (2*row0 + row1 + offset) % rows
              col_index = (2*col0 + col1 + offset) % cols
              # add the indexed Cell to the Box
              box << space[row_index][col_index]
            end
          end
        end
      end
    end

    # Tick each box in this Grid.
    def tick()
      @boxes.each { |box| box.tick }
    end
  end  # class SimFrost::Grid


  # Creates the space and the two alternate Grids and initializes the
  # time counter to 0.
  def initialize(rows, columns, vapor_rate)
    # argument checks
    raise ArgumentError, "rows and columns must be positive" unless
      rows > 0 && columns > 0
    raise ArgumentError, "rows and columns must be even" unless
      rows % 2 == 0 && columns % 2 == 0
    raise ArgumentError, "vapor rate must be from 0.0 to 1.0" unless
      vapor_rate >= 0.0 && vapor_rate <= 1.0

    # Create the space with the proper vapor ratio.
    @space = Array.new(rows) do
      Array.new(columns) do
        Cell.new(rand <= vapor_rate ? :vapor : :space)
      end
    end

    # Put one ice crystal in the middle.
    @space[rows/2][columns/2].contents = :ice

    # Create the two Grids by using different offsets.
    @grids = [Grid.new(@space, 0), Grid.new(@space, 1)]

    @time = 0
  end

  # Returns true if there's any vapor left in @space
  def contains_vapor?
    @space.flatten.any? { |cell| cell.contents == :vapor }
  end

  # Alternates which Grid is used during each tick and adjust the
  # Cells in each Box.
  def tick
    @grids[@time % 2].tick
    @time += 1
  end

  def to_s
    @space.map do |row|
      row.map { |cell| cell.to_s }.join('')
    end.join("\n")
  end
end  # class SimFrost


if __FILE__ == $0
  # choose command-line arguments or default values
  rows       = ARGV[0] && ARGV[0].to_i || 30
  columns    = ARGV[1] && ARGV[1].to_i || 60
  vapor_rate = ARGV[2] && ARGV[2].to_f || 0.15
  pause      = ARGV[3] && ARGV[3].to_f || 0.025

  s = SimFrost.new(rows, columns, vapor_rate)
  puts s.to_s
  while s.contains_vapor?
    sleep(pause)
    s.tick
    puts "=" * columns  # separator
    puts s.to_s
  end
end
