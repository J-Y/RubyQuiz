# Ruby Quiz 125: Fractals
# turtle_text.rb

require 'turtle'

# Contains the textize method for creating a text representation of a turtle
# graphic.
module TurtleText
  BG         = ' '
  Vertical   = '|'
  Horizontal = '_'

  # Returns a string representation for the given turtle graphics string.
  # Too bad Turtle.each_coord doesn't seem to be usable here, what with the
  # special x & y adjustments and such.
  def TurtleText.textize turtle
    x, y, grid = 0, 0, []
    last_abs_dir = nil

    # These two derement procs will automatically shift things up or right if
    # the values try to go below zero.
    decrement_x = lambda do
      if x > 0 then x -= 1
      else grid.each { |row| row.insert(0, nil) } end
    end
    decrement_y = lambda do
      if y > 0 then y -= 1
      else grid.insert 0, [] end
    end

    Turtle.each_absolute_direction(turtle) do |abs_dir|
      grid[y] = [] if grid[y].nil? # Hmm.. any way to give an array a default?

      if abs_dir == Turtle::Up
        grid[y][x] = Vertical
        y += 1
      elsif abs_dir == Turtle::Right
        x += 1 if not last_abs_dir.nil?
        grid[y][x] = Horizontal
        x += 1
      elsif abs_dir == Turtle::Down
        decrement_y[]
        grid[y][x] = Vertical
      else # abs_dir == Turtle::Left
        decrement_x[] if not last_abs_dir.nil?
        grid[y][x] = Horizontal
        decrement_x[]
      end

      last_abs_dir = abs_dir
    end

    # Convert grid to a string, reversing first since its upside-down.
    grid.reverse.inject('') do |str, row|
      str + row.map { |v| v.nil? ? BG : v }.join + "\n" 
    end.chomp
  end
end
