#!/usr/bin/env ruby

# frost.rb
# see http://rubyquiz.com/quiz117.html for details
# Author: Tom Rauchenwald <its.sec@gmx.net>

class Cell
  attr_reader :kind
  
  def initialize kind
    if kind!=:vapor && kind !=:ice && kind != :vacuum
      raise "Cell has to be either :ice, :water or :vacuum!"
    end
    @kind=kind
  end

  def kind=(kind)
    if kind!=:vapor && kind !=:ice && kind != :vacuum
      raise "Cell has to be either :ice, :water or :vacuum!"
    end
    @kind=kind
  end
  
  def kind? kind
    kind==@kind
  end

  def to_s
    case kind
    when :vacuum; " "
    when :ice;    "*"
    when :vapor;  "`"
    end
  end
end
 
class Board
  def initialize x,y,s,pv
    @x=x; @y=y; @sleeptime=s.to_f/1000
    # create Board and fill it with Cells
    @board=Array.new(@x) { Array.new(@y) {Cell.new :vacuum } }
    @board[@x]=@board[0]  # Make last and first column the same object
    # same for last and first row
    (@x+1).times do |x|
      @board[x][@y]=@board[x][0]
    end
    # this will track how man vapor particles are on the board
    # scanning the board each tick would be a waste of time
    @n_vapor=0
    if pv < 100 && pv > 0
      @p_vapor=pv.to_f/100
    else
      @p_vapor=0.3
    end
    # this will toggle between 0 and 1, more is not necessary as
    # outlined in the quiz description 
    @tick=0
  end

  def init_board
    # clear board
    @x.times do |x|
      @y.times do |y|
        @board[x][y].kind=:vacuum
      end
    end
    @n_vapor=0;
    # place the ice at the center
    @board[@x/2][@y/2].kind=:ice
    # place vapor randomly
    while @n_vapor.to_f/(@x*@y) < @p_vapor
      x,y = rand(@x), rand(@y)
      if @board[x][y].kind?(:vacuum)
        @board[x][y].kind=:vapor; @n_vapor += 1
      end
    end
  end
  
  def to_s
    res = "´" + "-"*@x + "`\n"
    (@y).times do |y|
      res << "|"
      (@x).times do |x|
        res << @board[x][y].to_s
      end
      res << "|\n"
    end
    res += "`" + "_"*@x + "´\n"
    return res
  end

  def tick
    # copy first column to last column
    (@tick...(@y+@tick)).step(2) do |y|
      (@tick...(@x+@tick)).step(2) do |x|
        # check if ice is in the neighbourhood
        if [@board[x][y], @board[x+1][y], @board[x][y+1], @board[x+1][y+1]].any? { |i| i.kind? :ice }
          # there is, change vapor to ice
          [@board[x][y], @board[x+1][y], @board[x][y+1], @board[x+1][y+1]].each do |i|
            if i.kind? :vapor
              i.kind=:ice
              @n_vapor-=1 
            end
          end
        else
          # no ice, rotate neighbourhood clockwise or counter clockwise
          if rand(2)==0
            @board[x][y].kind, @board[x+1][y].kind, @board[x+1][y+1].kind, @board[x][y+1].kind = 
              @board[x][y+1].kind, @board[x][y].kind, @board[x+1][y].kind, @board[x+1][y+1].kind
          else
            @board[x][y].kind, @board[x+1][y].kind, @board[x+1][y+1].kind, @board[x][y+1].kind = 
              @board[x+1][y].kind, @board[x+1][y+1].kind, @board[x][y+1].kind, @board[x][y].kind
          end
        end
      end
    end
    @tick=(@tick+1)%2 # toggle tick
  end

  def start
    puts "\033[2J"  # clear terminal and move cursor to upper left
    while @n_vapor>0
      puts "\033[0;0f" # move cursor to upper left
      puts self.to_s
      tick
      sleep @sleeptime
    end
    puts "\033[0;0f"
    puts self.to_s
  end
end

if ARGV.length<2
  puts "Usage: " + __FILE__ + " <sizeX> <sizeY> <sleeptime>"
  puts "Sleeptime is optional (in milliseconds). X and Y must be even numbers."
  exit 1
end

x = ARGV[0].to_i; 
y = ARGV[1].to_i;
s = !ARGV[2] ? 20 : ARGV[2].to_i;
pv = !ARGV[3] ? 30 : ARGV[3].to_i;

b=Board.new(x, y, s, pv)
loop do
  b.init_board
  b.start
  print "Again? (y/n): "
  break if STDIN.gets.chomp.downcase != "y"
end
