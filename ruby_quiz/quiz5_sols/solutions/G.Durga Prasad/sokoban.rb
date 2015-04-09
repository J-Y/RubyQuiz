# solution to [QUIZ] Sokoban (#5)
# G.D.Prasad , 1st Nov , 04  ,  5.00 PM
# run as ----     ruby sokoban.rb sokobangame

#file sokoban.rb

require 'curses'
include Curses
$a= []
i=0
file = File.new(ARGV[0],"r")
while line =file.gets
  lineArr=line.split("")
  $a << lineArr
  if  lineArr.include?("@")
        $x= lineArr.index("@")
        $y= i
  end
  i += 1
end

  $M = '@'
  $C='o'
  $W='#'
  $F= " "
  $S='.'
  $CS='*'
  $MS='+'

class Store
  HEIGHT = 10
  STORE =$a
  def initialize
    @top = (Curses::lines - HEIGHT)/2
    draw
  end
  def left
  $x=STORE[$y].index("@") || STORE[$y].index("+")
  temp=STORE[$y][$x-1]
  case temp
        when $F
                if  STORE[$y][$x-1,2]==[$F,$M]
                 STORE[$y][$x-1,2]=[$M,$F]
                elsif STORE[$y][$x-1,2]==[$F,$MS]
                 STORE[$y][$x-1,2]=[$M,$S]
                end
        when  $C
                if STORE[$y][$x-2] == $F
                        STORE[$y][$x-2,3]=[$C,$M,$F]
                elsif STORE[$y][$x-2] == $S
                        STORE[$y][$x-2,3]=[$CS,$M,$F]
                end
        when  $CS
                if STORE[$y][$x-2,3] == [$S,$CS,$M]
                        STORE[$y][$x-2,3]=[$CS,$M,$F]
                end
        when $S
                if STORE[$y][$x-2,3]==[$S,$S,$M]
                STORE[$y][$x-2,3]=[$S,$MS,$F]
                elsif STORE[$y][$x-1,2]==[$S,$MS]
                           STORE[$y][$x-1,2]=[$MS,$S]
                else
                        STORE[$y][$x-1,2]=[$MS,$F]
                end
        else beep
  end
  end

  def right
  $x=STORE[$y].index("@") || STORE[$y].index("+")
  temp=STORE[$y][$x+1]
  case temp
        when $F
                if  STORE[$y][$x,2]==[$M,$F]
                 STORE[$y][$x,2]=[$F,$M]
                elsif STORE[$y][$x,2]==[$MS,$F]
                 STORE[$y][$x,2]=[$S,$M]
        end
        when  $C
                if STORE[$y][$x+2] == $F
                        STORE[$y][$x,3]=[$F,$M,$C]
                elsif STORE[$y][$x+2] == $S
                        STORE[$y][$x,3]=[$F,$M,$CS]
                end
        when  $CS
                if STORE[$y][$x,3] == [$M,$CS,$S]
                        STORE[$y][$x,3]=[$F,$MS,$CS]
                end
        when $S
                if STORE[$y][$x,3]==[$M,$S,$S]
                STORE[$y][$x,3]=[$F,$MS,$S]
                elsif STORE[$y][$x,2]==[$MS,$S]
                           STORE[$y][$x,2]=[$S,$MS]
                elsif STORE[$y][$x,2]==[$M,$S]
                           STORE[$y][$x,2]=[$F,$MS]
                end
        else beep
  end
  end
  def up
  $x=STORE[$y].index("@") || STORE[$y].index("+")
  temp=STORE[$y-1][$x]
  case temp
        when $F
                if [ STORE[$y][$x],STORE[$y-1][$x] ]==[$M,$F]
                 STORE[$y][$x],STORE[$y-1][$x]=$F,$M
                 $y -= 1
                elsif [ STORE[$y][$x],STORE[$y-1][$x] ]==[$MS,$F]
                 STORE[$y][$x],STORE[$y-1][$x]=$S,$M
                 $y -= 1
                end
        when  $C
                if STORE[$y-2][$x] == $F
                 STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]=$F,$M,$C
                 $y -= 1
                elsif STORE[$y-2][$x] == $S
                 STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]=$F,$M,$CS
                 $y -= 1
                end
        when  $CS
                if [STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]]==
[$M,$CS,$S]                
STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]=$F,$MS,$CS
                 $y -= 1
                elsif
[STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]]== [$MS,$CS,$S]
                 STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]=$S,$MS,$CS
                 $y -= 1
                end
        when $S
                if [STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]]==[$M,$S,$S]
                STORE[$y][$x],STORE[$y-1][$x],STORE[$y-2][$x]=$F,$MS,$S
                 $y -= 1
                elsif [STORE[$y][$x],STORE[$y-1][$x]]==[$MS,$S]
                 STORE[$y][$x],STORE[$y-1][$x]=$S,$MS
                 $y -= 1
                elsif [STORE[$y][$x],STORE[$y-1][$x]]==[$M,$S]
                 STORE[$y][$x],STORE[$y-1][$x]=$F,$MS
                 $y -= 1
                end
        else beep
  end
  end
  def down
  $x=STORE[$y].index("@") || STORE[$y].index("+")
  temp=STORE[$y+1][$x]
  case temp
        when $F
                if [ STORE[$y][$x],STORE[$y+1][$x] ]==[$M,$F]
                 STORE[$y][$x],STORE[$y+1][$x]=$F,$M
                 $y += 1
                elsif [ STORE[$y][$x],STORE[$y+1][$x] ]==[$MS,$F]
                 STORE[$y][$x],STORE[$y+1][$x]=$S,$M
                 $y += 1
                end
        when  $C
                if STORE[$y+2][$x] == $F
                 STORE[$y][$x],STORE[$y+1][$x],STORE[$y+2][$x]=$F,$M,$C
                 $y += 1
                elsif STORE[$y+2][$x] == $S
                 STORE[$y][$x],STORE[$y+1][$x],STORE[$y+2][$x]=$F,$M,$CS
                 $y += 1
                end
        when  $CS
                if [STORE[$y][$x],STORE[$y+1][$x],STORE[$y+2][$x]]==
[$M,$CS,$S]                
STORE[$y][$x],STORE[$y+1][$x],STORE[$y+2][$x]=$F,$MS,$CS
                 $y += 1
                end
        when $S
                if [STORE[$y][$x],STORE[$y+1][$x],STORE[$y+2][$x]]==[$M,$S,$S]
                STORE[$y][$x],STORE[$y+1][$x],STORE[$y+2][$x]=$F,$MS,$S
                 $y += 1
                elsif [STORE[$y][$x],STORE[$y+1][$x]]==[$MS,$S]
                 STORE[$y][$x],STORE[$y+1][$x]=$S,$MS
                 $y += 1
                elsif [STORE[$y][$x],STORE[$y+1][$x]]==[$M,$S]
                 STORE[$y][$x],STORE[$y+1][$x]=$F,$MS
                 $y += 1
                end
        else beep
  end
  end
  def draw
    setpos(@top-1, 0)
    addstr(STORE.to_s)
    refresh
  end
end

init_screen
begin
  crmode
  noecho
  stdscr.keypad(true)

  store = Store.new

  loop do
    case getch
    when ?Q, ?q    :  break
    when Key::LEFT   :  store.left
    when Key::RIGHT :  store.right
    when Key::UP   :  store.up
    when Key::DOWN   :  store.down
    else beep
    end
    store.draw
  end
ensure
  close_screen
end
