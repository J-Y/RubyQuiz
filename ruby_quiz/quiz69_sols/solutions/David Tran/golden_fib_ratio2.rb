puts "Usage  #$0  filename"; exit(1)) unless ARGV[0]

require 'pdf/writer'

pdf = PDF::Writer.new
pdf.translate_axis(100, 100)
s = 400
colors = [0.7, 0.5, 0.3].map { |e| Color::GrayScale.from_fraction(e) }
phi = (Math.sqrt(5) - 1 ) / 2

def box(i, pdf)
  pdf.move_to(0,0).line_to(i,0).line_to(i,i).line_to(0,i).close_fill
  pdf.move_to(0,0).line_to(i,0).line_to(i,i).line_to(0,i).close_stroke
end

style = pdf.stroke_style?

10.times do |i|
  pdf.fill_color(colors[i % colors.size])
  pdf.stroke_color(Color::RGB::Black)
  box(s, pdf)
  pdf.stroke_color(Color::RGB.from_fraction(0.8, 0.4, 0))
  pdf.ellipse2_at(0, s, s, s, 0, -90).stroke
  pdf.translate_axis(s, s)
  pdf.rotate_axis(90)
  pdf.scale_axis(phi, phi)
  style.width /= phi
  pdf.stroke_style!(style)
end

pdf.save_as(ARGV[0])
