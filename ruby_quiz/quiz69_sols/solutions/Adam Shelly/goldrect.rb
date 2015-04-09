#----- goldrect.rb
#
#  Submission for Ruby Quiz #69
#  by Adam Shelly
#
require 'ncurses'


class FibBox
  Direction=[:up,:left,:down,:right]
  @@boxes = []

  def self.moveall y,x
    @@boxes.each{|f| f.moverel(y,x,true)}
    @@boxes.each{|b| b.unhide}
  end
  def self.animate isize=1
    size = [isize,isize]
    f = FibBox.new(Direction[dir=2],size,[0,0])
    while true
      n = size.max
      pos = [0,0]
      pos[0]+=size.min if dir==2
      pos[1]+=size.min if dir==3
      n==size[1] ? size[0]+=n : size[1]+=n
      break if (size[0] > Ncurses.LINES) || (size[1] > Ncurses.COLS)
      f = FibBox.new(Direction[dir],[n,n],pos)
      dir=(dir+1)%4
    end
  end

  def initialize dir,size,pos
    @size = size
    @pos = pos
    func = lambda{FibBox.moveall(0,1)} if dir==:left
    func = lambda{FibBox.moveall(1,0)} if dir==:up
    case dir
      when :left, :right
        target = @size[1]
        parms=[@size[0],1]+@pos
        animate=1
      when :down, :up
        target = @size[0]
        parms=[1,@size[1]]+@pos
        animate=0
    end
    func.call if func
    win = Ncurses::WINDOW.new(*parms)
    @panel=win.new_panel
    show
    while parms[animate]!=target
      sleep(0.01)
      parms[animate]+=1
      func.call if func
      Ncurses::Panel.update_panels
      Ncurses.doupdate()
      resize(*parms)
    end
    @@boxes<<self
  end

  def hide
      @panel.window.border(*([' '[0]]*8))
  end
  def unhide
      @panel.window.border(*([0]*8))
  end
  def show
      unhide
      Ncurses::Panel.update_panels
      Ncurses.doupdate()
      sleep(0.1/@size[0]) #sleep less when box takes longer to draw
  end
  def resize(sy,sx,ly,lx)
    nw=Ncurses::WINDOW.new(sy,sx,ly,lx)
    exit(0) if !nw
    w = @panel.window
    @panel.replace(nw)
    w.delete
    show
  end
  def moverel(dy,dx,keephidden=false)
    hide
    @pos[0]+=dy
    @pos[1]+=dx
    @panel.move(*@pos)
    show unless keephidden
  end
end


if __FILE__ == $0
  if (ARGV[0].to_i)>0
    size = ARGV.shift.to_i
  end
  if RUBY_PLATFORM =~ /mswin/
    case ARGV[0]
      when '-h', '-?'
        puts "usage: #{$0} [size] [-newwin||-resize] [x y]"
        puts " size: initial box size (default 1)"
        puts " -resize: resizes your screen to x,y (default 150x90)"
        puts " -newwin: launches program in a new resized window"
        exit
      when '-newwin'
      `start /WAIT ruby #{$0} #{size||1} -resize #{ARGV[1]} #{ARGV[2]}`
       exit
      when '-resize'
        `mode con cols=#{ARGV[1]||150} lines=#{ARGV[2]||90}`
    end
  end
  Ncurses.initscr
  Ncurses.noecho
  FibBox.animate size||1
  Ncurses.stdscr.getch
end
