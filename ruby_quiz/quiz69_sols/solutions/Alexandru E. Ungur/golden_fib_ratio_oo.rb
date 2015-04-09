class GoldenRectangles
  def initialize
    @cell, @blank, @clear = "\033[34;1m##", "\033[37;1m##", "\033[30;0m"
  end

  def next_rectangle(a, b)
    [[a,b].max, [a,b].min + [a,b].max]
  end

  def show_rectangles(rect, count)
    if count > 0
      p rect
      side = ''
      rect[0].times { side = side + @cell }
      rect[1].times { side = side + @blank }
      rect[1].times { puts side }
      puts @clear
      rect = next_rectangle(rect[0], rect[1])
      show_rectangles(rect, count - 1)
    end
  end
end

GoldenRectangles.new.show_rectangles([1,1], 5)
