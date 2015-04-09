require 'java'
require "lib/turtle"

class TurtleView
   DEFAULT_FRAME = [[-200.0, 200.0], [200.0, -200.0]]

   attr_accessor :frame

   def initialize(turtle, canvas, frame=DEFAULT_FRAME)
      @turtle = turtle
      @canvas = canvas
      @frame = frame
      @turtles = []
   end

   def handle_map_event(w, h)
      top_lf, btm_rt = frame
      x0, y0 = top_lf
      x1, y1 = btm_rt
      @x_xform = make_xform(x0, x1, w)
      @y_xform = make_xform(y0, y1, h)
   end

   def draw
      g = @canvas.graphics
      @turtle.track.each do |seqment|
         if seqment.size > 1
            pts = seqment.collect { |pt| transform(pt) }
            g.drawLine(pts[0][0], pts[0][1], pts[1][0], pts[1][1])
         end
      end
   end

   def transform(turtle_pt)
      x, y = turtle_pt
      [@x_xform.call(x), @y_xform.call(y)]
   end

private

   def make_xform(u_min, u_max, v_max)
      lambda { |u| v_max * (u - u_min) / (u_max - u_min) }
   end

end

JFrame = javax.swing.JFrame
JPanel = javax.swing.JPanel
Dimension = java.awt.Dimension
BorderLayout = java.awt.BorderLayout

class TurtleViewer
   def initialize(code)
      @code = code

      root = JFrame.new "Turtle Graphics Viewer"
      @canvas = JPanel.new
      root.get_content_pane.add @canvas, BorderLayout::CENTER
      root.set_default_close_operation(JFrame::EXIT_ON_CLOSE)
      root.set_preferred_size Dimension.new(440, 440)
      root.set_resizable false
      root.pack
      root.set_visible true
      run_code
   end

   def run_code
      turtle = Turtle.new
      view = TurtleView.new(turtle, @canvas)
      view.handle_map_event(@canvas.width,
                            @canvas.height)
      turtle.run(@code)
      view.draw
   end
end

# Commands to be run if no command line argument is given.
CIRCLE_DESIGN = <<CODE
def circle
   pd; 90.times { fd 6; rt 4 }; pu
end
18.times { circle; rt 20 }
CODE

if ARGV.size > 0
   code = open(ARGV[0]) { |f| f.read }
else
   code = CIRCLE_DESIGN
end
TurtleViewer.new(code)
