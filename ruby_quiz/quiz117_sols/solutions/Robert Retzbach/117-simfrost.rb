module SimFrost
  Ice    = "*"
  Vapor  = "."
  Vacuum = " "

  class Simulation
    def initialize x = 80, y = 23
      @grid = Grid.new x, y
      @ticks = 0
    end
    def start
      set_cursor_to_home
      clear_screen

      show_grid

      while @grid.contains? Vapor
        force_delay

        proc_tick 

        set_cursor_to_home
        show_grid        
      end

      clear_line
    end
    def show_grid
      puts @grid
    end
    def create_xpm
      # left pad with 0 in order to sync filename with sequence
      File.open("ice#{@ticks.to_s.rjust(7).tr(' ','0')}.xpm", "w") do |fh|
        fh.puts <<-HERE.gsub(/^ +/, "")
          /* XPM */
          static char * ice_xpm[] = {
            "#{@grid.width} #{@grid.height} 3 1",
            "#{Ice}	c #ffffff",
            "#{Vapor}	c #4e5a8e",
            "#{Vacuum}	c #0c184c",
            #{@grid.to_xpm}
          };
        HERE
      end
    end
    
    private
    def force_delay
      sleep 0.01
    end    
    def clear_screen
      print "\e[2J"
    end
    def set_cursor_to_home
      print "\e[1;1H"
    end
    def clear_line
      print "\e[K"
    end
    def proc_tick
      @ticks += 1

      @grid.shift_cells(1) if @ticks % 2 == 1

      @grid.replace_neighborhoods do |neighborhood|
        if neighborhood.any?{|cell| cell == Ice}
          freeze_vapor neighborhood
        else
          rotate_neighborhood neighborhood
        end
      end

      @grid.shift_cells(-1) if @ticks % 2 == 1
    end
    def freeze_vapor arr
      arr.map{|cell| (cell == Vapor) ? Ice : cell}
    end
    def rotate_neighborhood arr
      if rand(2) == 0
        rotate_neighborhood_cw arr       
      else
        rotate_neighborhood_ccw arr
      end
    end
    def rotate_neighborhood_cw arr
      [arr[2], arr[0], arr[3], arr[1]]
    end
    def rotate_neighborhood_ccw arr
      [arr[1], arr[3], arr[0], arr[2]]
    end
  end

  class Grid
    attr_reader :width, :height

    def initialize x, y
      @width = Integer(x)
      @height = Integer(y)

      [@width, @height].each do |num|
        raise ArgumentError, "Number must be greater than two: #{num}" unless num > 2
        raise ArgumentError, "Number must be divisible by two: #{num}" unless num % 2 == 0
      end

      @canvas = Array.new(@height){Array.new(@width)}

      place_things
    end
    def place_things
      place_vapor_and_vacuum
      place_ice
    end
    def place_vapor_and_vacuum
      percentage = 25
      replace_cells do |cell|
        if rand(100) > percentage
          Vacuum
        else
          Vapor
        end
      end
    end
    def place_ice
      self[get_middle_pos] = Ice
    end
    def shift_cells offset
      @canvas = shift_flat(@canvas, offset).map do |row|
        shift_flat row, offset
      end
    end
    def replace_neighborhoods
      (@height/2).times do |y|
        (@width/2).times do |x|
          neighborhood = @canvas[y*2][x*2..x*2+1] + @canvas[y*2+1][x*2..x*2+1]

          neighborhood = yield neighborhood

          @canvas[y*2][x*2..x*2+1] = neighborhood[0..1]
          @canvas[y*2+1][x*2..x*2+1] = neighborhood[2..3]
        end
      end
    end
    def get_middle_pos
      [@width/2, @height/2]
    end
    def contains? thing
      @canvas.flatten.any?{|cell| cell == thing}
    end
    def []= pos, val
      @canvas[pos.last][pos.first] = val
    end
    def replace_cells &block
      @canvas.map!{|cell| cell.map!(&block)}
    end
    def to_s
      @canvas.map{|cell| cell.map{|x| x.to_s}.join}.join("\n")
    end
    def to_xpm
      @canvas.map{|cell| '"' + cell.map{|x| x.to_s}.join + '"'}.join(",\n")
    end

    private
    def shift_flat arr, offset
      arr[offset..-1] + arr[0..-1+offset]
    end
  end
end

if $0 == __FILE__
  include SimFrost
  Simulation.new(*(ARGV[0..1])).start
end
