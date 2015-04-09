require 'Complex'

class MandelbrotImage
  def initialize(data, max_iterations)
    @data = data
    @max_iterations = max_iterations
  end
  
  def to_s
    s = ""
    @data.each do |row|
      row.each do |i|
        case i
        when 0..5
          s << '  '
        when @max_iterations
          s << '##'
        else
          s << '..'
        end
      end
      s << "\n"
    end
    s
  end
end

class Mandelbrot
  def initialize(img_width, img_height)
    @img_width = img_width
    @img_height = img_height
  end

  def render(center, width, max_iterations=1000)
    from, to = convert_coords(center, width)
    pixel_size_y = (to.image - from.image)/@img_height
    pixel_size_x = (to.real - from.real)/@img_width
    image_data = []
    (from.image..to.image).step(pixel_size_y) do |yc|
      row = []
      (from.real..to.real).step(pixel_size_x) do |xc|
        c = Complex.new(xc, yc)
        z = Complex.new(0.0, 0.0)
        iteration = 0
        while z.abs < 2.0 and iteration < max_iterations
          z = z**2 + c
          iteration += 1
        end
        row << iteration
      end
      image_data << row
    end
    MandelbrotImage.new(image_data, max_iterations)
  end
  
  private
  
  def convert_coords(center, width)
    aspect = @img_height.to_f / @img_width.to_f
    height = width * aspect
    from = Complex.new(center.real - width/2.0, center.image - height/2.0)
    to = Complex.new(center.real + width/2.0, center.image + height/2.0)
    return from, to
  end
end

mandel = Mandelbrot.new(30, 20)
image = mandel.render(Complex.new(-0.7, 0.0), 3.0769)
puts image
image = mandel.render(Complex.new(-0.743643135, 0.131825963), 4.3884e-06, 2000)
puts image
