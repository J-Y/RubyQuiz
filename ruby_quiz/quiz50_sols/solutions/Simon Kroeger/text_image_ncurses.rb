require 'RMagick'
require "ncurses"

Ncurses.initscr
puts "Usage: #{$0} <img> [size]" or exit if !ARGV[0]
puts "Sorry, no colors!" or exit unless Ncurses.has_colors?

img, size = Magick::ImageList.new(ARGV[0]), (ARGV[1]||40).to_f
factor = [size*2/img.rows, size/img.columns].min
img.resize!(img.columns*factor, (img.rows*factor*0.5).round)

COLORS =
  [[Ncurses::COLOR_BLACK, [0, 0, 0]], [Ncurses::COLOR_RED, [1, 0, 0]],
  [Ncurses::COLOR_GREEN, [0, 1, 0]], [Ncurses::COLOR_BLUE, [0, 0, 1]],
  [Ncurses::COLOR_YELLOW, [1, 1, 0]], [Ncurses::COLOR_MAGENTA, [1, 0, 1]],
  [Ncurses::COLOR_CYAN, [0, 1, 1]], [Ncurses::COLOR_WHITE, [1, 1, 1]]]

GRADIENT = [[0, ' '], [50, ':'], [100, '|'], [150, 'I'], [200, '#']]
COLORMAP = {}

COLORS.size.times do |bg|
  COLORS.size.times do |fg|
    next if fg == bg
    i = (bg*COLORS.size) + fg
    Ncurses.init_pair(i, COLORS[fg][0], COLORS[bg][0])
    GRADIENT.each do |gr, c|
      r = COLORS[fg][1][0] * gr + COLORS[bg][1][0] * (255-gr)
      g = COLORS[fg][1][1] * gr + COLORS[bg][1][1] * (255-gr)
      b = COLORS[fg][1][2] * gr + COLORS[bg][1][2] * (255-gr)
      COLORMAP[[r, g, b]] = [i, c]
    end
  end
end

#(16*16*4).times do |i|
#  Ncurses.stdscr.attrset(Ncurses.COLOR_PAIR(i))
#  Ncurses.stdscr.mvaddstr(i/16, (i%16)*4, 'TEST')
#end
#Ncurses.refresh

pixels = img.get_pixels(0, 0, img.columns, img.rows)
img.rows.times do |y|
  img.columns.times do |x|
    p = pixels[y*img.columns + x]
    r, g, b, best, dist = p.red, p.green, p.blue, -1, 255
    COLORMAP.each do |k, v|
      d = Math.sqrt((r-k[0])**2 + (g-k[1])**2 + (b-k[2])**2)
      (best, dist = v, d) if d < dist
    end
    Ncurses.stdscr.attrset(Ncurses.COLOR_PAIR(best[0]))
    Ncurses.stdscr.mvaddstr(y, x, best[1])
  end
end

Ncurses.refresh
