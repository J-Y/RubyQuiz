require 'curses'
require 'sokoban'

sokoban = Sokoban.new
sokoban.load_levels( File.read( 'sokoban_levels.txt' ) )

puts "Welcome to Curses-Sokoban!"
print "Select the level (0..#{sokoban.levels.length-1}): "
sokoban.select_level( gets.to_i )

Curses::init_screen
Curses::noecho
width = sokoban.cur_level.map.width + 4
height = sokoban.cur_level.map.height + 4
win = Curses::Window.new( height, width, (Curses::lines - height) / 2 , (Curses::cols - width) / 2 )
win.box( ?|, ?- )
win.keypad = true

begin
  y = 2
  sokoban.cur_level.map.each_row do |item|
    win.setpos( y, 2 )
    win.addstr( item.pack('C*') )
    y += 1
  end
  win.refresh

  char = win.getch
  case char
  when ?w, Curses::Key::UP then sokoban.cur_level.move( :up )
  when ?s, Curses::Key::DOWN then sokoban.cur_level.move( :down )
  when ?a, Curses::Key::LEFT then sokoban.cur_level.move( :left )
  when ?d, Curses::Key::RIGHT then sokoban.cur_level.move( :right )
  end
end while char != ?q && !sokoban.cur_level.level_finished?
win.close
Curses::close_screen

if sokoban.cur_level.level_finished?
  puts "You are the greatest player in history!!!"
else
  puts "You have given up too easily!!!"
end

