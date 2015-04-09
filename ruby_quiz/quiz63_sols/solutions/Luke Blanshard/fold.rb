#!/usr/bin/ruby -w
#
# Ruby Quiz #63, Grid Folding

require "strscan"

# Creates the grid, applies the folds to it
def fold( v, h, folds )
  grid = Array.new(v){|i|Array.new(h){|j|[j*v+i+1]}}
  s, c = StringScanner.new(folds), ""
  grid.send("fold_"+c+"!") while c=s.getch
  raise "Too few folds" if grid.size != 1 or grid[0].size != 1
  grid[0][0]
end

class Array
  # Slices self in half, yields removed and retained elements
  def fold!(forward)
    raise "Can't fold odd-sized array" if size[0] == 1
    start = if forward then 0 else size/2 end
    a = slice! start, size/2
    zip(a.reverse!){|e|yield e[1], e[0]}
  end

  # Vertical fold, top to bottom or vice versa
  def fold_v!(down)
    each{|c|c.fold!(down){|a,b|b.unshift(*a.reverse!)}}
  end

  # Horizontal fold, left to right or vice versa
  def fold_h!(left)
    fold!(left){|a,b|a.each_index{|i|b[i].unshift(*a[i].reverse!)}}
  end

  def fold_T!; fold_v! true;  end
  def fold_B!; fold_v! false; end
  def fold_L!; fold_h! true;  end
  def fold_R!; fold_h! false; end
end

# Parses ARGV, returns v, h, folds
def get_args
  def usage
    puts "Usage: #{File.basename($0)} [<size>] <folds>\n"+
      "  where <size> is a power of 2 or a pair thereof separated by 'x', like 4x8\n"+
      "  and <folds> is a string of fold directions from T, L, R, B\n"
    exit
  end
  usage unless (1..2) === ARGV.size
  size, folds = [16, 16], ARGV[-1]
  usage unless folds =~ /^[TLRB]+$/
  if ARGV.size == 2
    size = ARGV[0].split('x').map{|s|s.to_i}
    usage unless (1..2) === size.size
    size = Array.new(2, size[0]) if size.size == 1
    size.each{|i|raise "%d not a power of 2"%i unless i>0 and i&(i-1)==0}
  end
  v, h = *size
  return v, h, folds
end

# Main program
if $0 == __FILE__
  p fold( *get_args )
end
#!/usr/bin/ruby -w

require 'fold.rb'


class Integer
  def bits
    return 0 if self <= 1
    return 1+(self/2).bits
  end
end

if $0 == __FILE__
  v, h, folds = get_args
  bits = v.bits + h.bits
  puts fold(v, h, folds).map{|i|sprintf "%0*b", bits, i-1}
end
