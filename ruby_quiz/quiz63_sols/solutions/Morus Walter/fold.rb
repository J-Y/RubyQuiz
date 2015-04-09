#! /usr/bin/ruby

class Sheet

  attr_reader :width, :height, :depth

  def check(dim)
    n = Math.log(dim)/Math.log(2) # ' /x
    if n != n.to_i
           raise "dimension must be power of 2"
       end
  end
  def initialize(width, height)
    check(width)
    check(height)
    sheet = []
    0.upto(height-1) do | y |
      sheet[y] = []
      0.upto(width-1) do | x |
        sheet[y][x] = [ width*y + x ]
      end
    end
    set_sheet(sheet)
  end

  def set_sheet(sheet)
    @sheet = sheet
    @width = sheet[0].size
    @height = sheet.size
    @depth = sheet[0][0].size
  end

  def output()
    0.upto( height-1 ) do | y |
      0.upto( width-1 ) do | x |
        (depth-1).downto( 0 ) do | z |
          print "%3d " % (@sheet[y][x][z]+1)
        end
        print "    "
      end
      puts ""
    end
    puts ""
  end

  def result
    @sheet[0][0].reverse.collect { | i | i+1 }
  end

  # ok, here comes the ugly part...
  # for each folding direction a new (stacked) sheet is calculated
  def fold(dir)
    new_sheet = []
    if dir == "T"
      s2 = height/2 # i'd really liked to know why xemacs has problems with foo/2; probably it's confused with a regex
      raise "cannot fold" if s2 == 0
      0.upto( s2-1 ) do | y |
        new_sheet[y] = @sheet[y + s2]
        0.upto( width-1 ) do | x |
          0.upto( depth-1 ) do | z |
            new_sheet[y][x][depth+depth-1-z] = @sheet[s2-1-y][x][z]
          end
        end
      end
    elsif dir == "B"
      s2 = height/2 #'/x
      raise "cannot fold" if s2 == 0
      0.upto( s2-1 ) do | y |
        new_sheet[y] = @sheet[y]
        0.upto( width-1 ) do | x |
          0.upto(depth-1) do | z |
            new_sheet[y][x][depth+depth-1-z] = @sheet[s2+s2-1-y][x][z]
          end
        end
      end
    elsif dir == "L"
      s2 = width/2 #'/x
      raise "cannot fold" if s2 == 0
      0.upto( height-1 ) do | y |
        new_sheet[y] ||= []
        0.upto( s2-1 ) do | x |
          new_sheet[y][x] ||= []
          0.upto( depth-1 ) do | z |
            new_sheet[y][x][z] = @sheet[y][x+s2][z]
            new_sheet[y][x][depth+depth-1-z] = @sheet[y][s2-1-x][z]
          end
        end
      end
    elsif dir == "R"
      s2 = width/2 #'/x
      raise "cannot fold" if s2 == 0
      0.upto( height-1 ) do | y |
        new_sheet[y] ||= []
        0.upto( s2-1 ) do | x |
          new_sheet[y][x] ||= []
          0.upto( depth-1 ) do | z |
            new_sheet[y][x][z] = @sheet[y][x][z]
            new_sheet[y][x][depth+depth-1-z] = @sheet[y][s2+s2-1-x][z]
          end
        end
      end
    else
      raise "unknown edge #{dir}"
    end
    set_sheet(new_sheet)
  end

  def folds(dirs)
    dirs.split(//).each do | dir |
      fold(dir)
    end
  end

end

def fold(width, height, cmds)
  sheet = Sheet.new(width, height)
  sheet.folds(cmds)
  raise "to few folds..." if sheet.width > 1 || sheet.height > 1
  return sheet.result
end

if ARGV[0]
  cmds = ARGV[0]
  width = (ARGV[1] || 16).to_i
  height = (ARGV[2] || width).to_i
  digits = (Math.log(width*height)/Math.log(10)).ceil
  puts fold(width, height, cmds).collect { | i | "%#{digits}d" % i }.join(", ")
end

