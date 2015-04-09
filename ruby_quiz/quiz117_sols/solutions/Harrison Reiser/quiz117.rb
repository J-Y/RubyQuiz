require 'simfrost'
require 'curses'

win = Curses.init_screen

columns = win.maxx
lines = win.maxy

# ensure even numbers
columns -= columns % 2
lines -= lines % 2

frost = SimFrost.new(columns, lines)

while frost.step
  win.setpos(0,1)
  win << frost.to_s
  win.refresh
  win.getch
end
