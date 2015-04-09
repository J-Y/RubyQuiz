require 'tk'

class GoldenRect
  include Enumerable
  def initialize
    @w = @h = 1
  end

  def each
    inc_w = true
    loop do
      yield [@w, @h]
      inc_w ? (@w += @h) : (@h += @w)
      inc_w = !inc_w
    end
  end
end

canvas = TkCanvas.new() {
  xscrollbar(sb_x = TkScrollbar.new)
  yscrollbar(sb_y = TkScrollbar.new)
  Tk.grid( self, sb_y, :sticky=>:news )
  Tk.grid( sb_x, 'x',  :sticky=>:we )
  TkGrid.rowconfigure(Tk.root, 0, :weight=>1)
  TkGrid.columnconfigure(Tk.root, 0, :weight=>1)
}

thread = Thread.new(canvas) { |c|
  mx = my = 5   # margin x, y
  sx = sy = 10  # rectangle unit scale
  GoldenRect.new.each do |w, h|
    c.create(TkcRectangle, mx, my, mx + (w * sx), my + (h * sy))
    c.scrollregion([0, 0, (2 * mx) + (w * sx), (2 * my) + (h * sy)])
    sleep
  end
}

TkRoot.bind('space', proc { thread.wakeup })
Tk.mainloop
