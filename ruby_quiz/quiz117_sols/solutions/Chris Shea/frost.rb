require 'RMagick'

module Frost
  ICE = 0
  NEWICE = 1
  VAPOR = 2
  VACUUM = 3
  ICECOLOR = 'blue'

  class Window
    def initialize(width, height, vapor_chance)
      unless width % 2 == 0 and height % 2 == 0
        raise ArgumentError, "divisible by 2"
      end
      @width = width
      @height = height
      row = Array.new(width, Frost::VACUUM)
      @glass = Array.new(height) { row.dup }
      @image = Magick::ImageList.new

      #place random vapor
      0.upto(height - 1) do |row|
        0.upto(width - 1) do |col|
          @glass[row][col] = Frost::VAPOR if rand < vapor_chance
        end
      end

      #place first ice
      #@glass[height / 2][width / 2] = Frost::NEWICE
      @glass[rand(height)][rand(width)] = Frost::NEWICE

      @step = 0
      make_gif
    end

    def step
      neighborhood_starts.each do |start|
          n = find_neighbors(start)
          n.step
          @glass[start[0]][start[1]] = n.layout[0]
          @glass[start[0]][(start[1]+1) % @width] = n.layout[1]
          @glass[(start[0]+1) % @height][start[1]] = n.layout[2]
          @glass[(start[0]+1) % @height][(start[1]+1) % @width] = n.layout[3]
        end
      @step += 1
    end

    def neighborhood_starts
      starts = []
      offset = @step % 2
      offset.step(@height - 1, 2) do |row|
        offset.step(@width - 1, 2) do |col|
          starts << [row,col]
        end
      end
      starts
    end

    def find_neighbors(start)
      one = @glass[start[0]][start[1]]
      two = @glass[start[0]][(start[1] + 1) % @width]
      three = @glass[(start[0] + 1) % @height][start[1]]
      four = @glass[(start[0] + 1) % @height][(start[1] + 1) % @width]
      Frost::Neighborhood.new(one,two,three,four)
    end

    def done?
      @glass.each do |row|
        return false if row.include? Frost::VAPOR
      end
      true
    end

    def make_gif
      if @image.empty?
        @image.new_image(@width, @height)
      else
        @image << @image.last.copy
      end

      @glass.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if cell == Frost::NEWICE
            point = Magick::Draw.new
            point.fill(Frost::ICECOLOR)
            point.point(x,y)
            point.draw(@image)
          end
        end
      end
    end

    def create_animation
      @image.write("frost_#{Time.now.strftime("%H%M")}.gif")
    end

    def go
      until done?
        step
        make_gif
        print '.'
      end
      print "\ncreating animation... "
      create_animation
      puts 'done'
    end

  end

  class Neighborhood
    def initialize(one,two,three,four)
      @layout = [one,two,three,four]
      transform(Frost::NEWICE, Frost::ICE)
    end

    attr_reader :layout

    def step
      if ice?
        ice_over
      else
        rotate
      end
    end

    def ice?
      @layout.include? Frost::ICE
    end

    def rotate
      if rand(2).zero?
        @layout = [@layout[1],@layout[3],@layout[0],@layout[2]]
      else
        @layout = [@layout[2],@layout[0],@layout[3],@layout[1]]
      end
    end

    def transform(from, to)
      @layout.map! {|cell| cell == from ? to : cell}
    end

    def ice_over
      transform(Frost::VAPOR, Frost::NEWICE)
    end
  end

end

if __FILE__ == $0
  if ARGV.size != 3
    puts "frost.rb <width> <height> <vapor chance (float)>"
    puts "This shouldn't take too long: frost.rb 100 100 0.3"
    exit
  end
  width = ARGV[0].to_i
  height = ARGV[1].to_i
  vapor_percent = ARGV[2].to_f
  window = Frost::Window.new(width,height,vapor_percent).go
end
