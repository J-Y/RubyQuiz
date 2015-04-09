#  SimFrost, solution to RubyQuiz #117
#  by Harrison Reiser 2007-03-10

class SimFrost
  def initialize(width, height, vapor_ratio = 0.25)
    @height = height.to_i
    @width = width.to_i
    vapor_ratio = vapor_ratio.to_f

    raise "height must be even" if height % 2 == 1
    raise "width must be even" if width % 2 == 1

    # fill the matrix with random vapor
    @grid = Array.new(height) do |row|
      row = Array.new(width) { |x| x = rand < vapor_ratio ? :vapor : :vacuum }
    end

    # seed it with an ice particle
    @grid[height/2][width/2] = :ice

    @offset = 0
  end

  # advances the frost simulation by one tick
  # or returns false if it has already finished.
  def step
    # confirm the presence of vapor
    return false if @grid.each do |row|
      break unless row.each { |sq| break if sq == :vapor }
    end

    # for each 2x2 box in the grid
    (0...@height/2).each do |i|
      (0...@width/2).each do |j|
        # get the coordinates of the corners
        y0 = i + i + @offset
        x0 = j + j + @offset
        y1 = (y0 + 1) % @height
        x1 = (x0 + 1) % @width

        # check for ice
        if @grid[y0][x0] == :ice or @grid[y0][x1] == :ice or
           @grid[y1][x0] == :ice or @grid[y1][x1] == :ice
          # freeze nearby vapor
          @grid[y0][x0] = :ice if @grid[y0][x0] == :vapor
          @grid[y0][x1] = :ice if @grid[y0][x1] == :vapor
          @grid[y1][x0] = :ice if @grid[y1][x0] == :vapor
          @grid[y1][x1] = :ice if @grid[y1][x1] == :vapor
        else
          if rand < 0.5
            # rotate right-hand
            temp = @grid[y0][x0]
            @grid[y0][x0] = @grid[y1][x0]
            @grid[y1][x0] = @grid[y1][x1]
            @grid[y1][x1] = @grid[y0][x1]
            @grid[y0][x1] =  temp
          else
            # rotate left-hand
            temp = @grid[y0][x0]
            @grid[y0][x0] = @grid[y0][x1]
            @grid[y0][x1] = @grid[y1][x1]
            @grid[y1][x1] = @grid[y1][x0]
            @grid[y1][x0] = temp
          end
        end
      end
    end

    # toggle the offset
    @offset = @offset ^ 1
    true # report that progress has been made
  end

  def to_a; @grid; end

  def to_s
    @grid.map { |row| row.map { |sq| @@asciifrost[sq] }.join }.join
  end

  # maps frost symbols to characters
  @@asciifrost = { :vapor => '.', :ice => '*', :vacuum => ' ' }
end
