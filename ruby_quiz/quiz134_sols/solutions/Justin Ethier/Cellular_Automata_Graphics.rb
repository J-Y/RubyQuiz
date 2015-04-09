# Justin Ethier
# August 2007
# 
# Solution to Ruby Quiz #134
# 
# Quiz Description: http://www.rubyquiz.com/quiz134.html
# Background information: http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
# 

require 'Cellular_Automata.rb'
require 'RMagick'
include Magick

class CellularAutomataGraphics
  def initialize
    # Define mappings from data coords to gfx coords
    # Basically this will make each pixel this many times
    # bigger in the final picture
    @x_map = @y_map = 10
  end
  
  # Draw the given list of fractal traces to file
  def draw(rule, steps, state, filename)
    cell = CellularAutomata.new
    data = cell.run(rule, steps, state)
    
    canvas = Magick::ImageList.new
    canvas.new_image(
      @x_map * steps * 2, # width
      @y_map * steps,     # height 
      Magick::HatchFill.new('white', 'white'))

    # Draw the fractal
    do_draw(canvas, data)
    
    # Write to file
    canvas.write(filename)  
  end
  
  # Do the actual drawing
  def do_draw(canvas, data)
      draw = Magick::Draw.new
      draw.fill('green')
      
      data.size.times do |y|
        data[y].size.times do |x|
          if data[y][x] == 1
            draw.rectangle(
              x * @x_map, y * @y_map,
              x * @x_map + @x_map, y * @y_map + @y_map)
          end
        end
      end
      
      draw.draw(canvas)
  end
  
  private :do_draw
end

if ARGV.size == 3
  cg = CellularAutomataGraphics.new
  cg.draw(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].split("").map{|i| i.to_i },
    sprintf("cellular_automata_%03d.jpg", ARGV[0].to_i))
else
  print "Usage: Cellular_Automata_gfx.rb rule_number number_of_steps initial_state"
end