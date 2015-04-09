# Ruby Quiz 125: Fractals
# turtle_draw.rb

require 'turtle'
require 'RMagick'

class TurtleDraw < Magick::Draw
  StrokeLength = 10 # pixels

  attr_reader :min_x, :min_y, :max_x, :max_y

  # Create a new TurtleDraw from the given string. x_ and y_translation are
  # extra (Cartesian) translations for the affine transform.
  def initialize turtle, x_translation = 0, y_translation = 0
    super()
    setup_attributes
    setup_affine turtle, x_translation, y_translation
    draw_turtle turtle
    self
  end

  # Setup all graphic attributes.
  def setup_attributes
    fill_opacity    0
    stroke          'gold3'
    stroke_width    2
    stroke_linecap  'round'
    stroke_linejoin 'round'
  end

  # The affine transform needs to do two things:
  #   - flip the coordinate system so y increases upwords (Cartesian)
  #   - shift to keep everything in the positive quadrant
  def setup_affine turtle, x_translation = 0, y_translation = 0
    min, max = Turtle.corners turtle
    @min_x, @min_y = min.map! { |v| StrokeLength * v }
    @max_x, @max_y = max.map! { |v| StrokeLength * v }
    affine 1, 0, 0, -1, -@min_x + x_translation , @max_y + y_translation
  end

  # Draw the given turtle string, setting the corner coords along the way.
  def draw_turtle turtle
    last_x = last_y = 0
    Turtle.each_coord(turtle, false) do |x, y|
      x, y = x * StrokeLength, y * StrokeLength
      line last_x, last_y, x, y
      last_x, last_y = x, y
    end
  end
end
