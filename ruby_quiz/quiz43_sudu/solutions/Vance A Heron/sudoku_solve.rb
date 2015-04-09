class Sudoku
  def initialize(dbg = false)
    @dbg = dbg
    @board = []
  end

  def read(fname = STDIN)
    while line = gets
      next unless line =~ /^[\d\|]/
      line.gsub!(/,/, ' ')if line =~ /^\d/   # to keep working w/old
boards
      @board << line.gsub(/\|/,'').split(' ').map{|p| p.to_i}
    end
  end

  def to_s
    tb = "+-------+-------+-------+\n"
    out = ''
    @board.each_with_index{|row,rndx|
      out += tb if rndx % 3 == 0
      row.each_with_index{|cell, cndx|
        out += '| ' if cndx % 3 == 0
        out += cell == 0 ? "_ " : "#{cell} "
      }
      out += "|\n"
    }
    out += tb
  end

  def solve
    begin
      fill_spec  # fill fully specified spaces
    rescue
      return     # if try made illegal partial ...
    end

    if count_zeros > 0  # some empty spaces
      sav = []
      copy_board(sav,@board)  # save last known legal bd
      x,y = first_zero
      choices = find_choices(x,y)
      choices.each{|v|      # try each possible choice for a 0
        copy_board(@board,sav)
        @board[x][y] = v
        puts "Try #{x},#{y} <- #{v}" if @dbg
        self.solve      # recurse...
        break if count_zeros == 0
      }
    end
  end

  # fill fully specified entries
  def fill_spec
    zeros = count_zeros        # how many to fill
    begin
      last_zeros = zeros
      (0..8).each{|i|
        (0..8).each{|j|
          next if @board[i][j] != 0   # skip filled spaces
          choices = find_choices(i, j)
          raise "Illegal Board #{i+1} #{j+1}" if choices.length == 0
          @board[i][j] = choices[0] if choices.length == 1
        }
      }
      zeros = count_zeros
    # if filled some, possibly others are now fully specified
    end while ((zeros > 0) &&  (last_zeros > zeros))
  end

  def find_choices (x, y)  # get all choices for a given location
    choices = Array.new(9) {|i| i+1}
    # remove numbers from same line & row
    (0..8).each{|i|
      choices[@board[x][i] -1] = 0 if (@board[x][i] != 0 )  # rm digits
in row
      choices[@board[i][y] -1] = 0 if (@board[i][y] != 0 )  # rm digits
in col
    }
    # remove numbers from same square ...
    xs = (x/3) * 3
    xe = xs + 2
    ys = (y/3) * 3
    ye = ys + 2
    (xs..xe).each{|i|
      (ys..ye).each{|j|
        choices[(@board[i][j]) - 1] = 0 if (@board[i][j] != 0)
      }
    }
    choices.delete_if {|v| v == 0}
  end

  def count_zeros  # to determine if I'm done ...
    @board.inject(0){|sum, row| sum += row.select{|e| e == 0}.length }
  end

  def copy_board(dst, src)
    (0..8).each{|i| dst[i] = src[i].dup}
  end
  def first_zero
    (0..8).each{|j| (0..8).each{|i| return i,j if @board[i][j] == 0 }}
  end

end

dbg = ARGV[0] =~ /-d/ ? true : false
ARGV.shift if dbg

bd = Sudoku.new(dbg)
bd.read(ARGV[0])
puts "Input\n#{bd}"
bd.solve
puts bd.count_zeros == 0 ?  "Solution\n#{bd}" : "Unsolvable\n#{bd}"
