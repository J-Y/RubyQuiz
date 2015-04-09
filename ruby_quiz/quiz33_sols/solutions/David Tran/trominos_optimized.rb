#--------------------------------------------------------------------
# Program : Solution for Ruby Quiz #33 Tiling Turmoil
# Author  : David Tran
# Date    : 2005-05-20
# Version : Without always recalculate "missing" cell
#--------------------------------------------------------------------

DIRECTION = [ [ 0,  3,  0,  1],
              [ 2,  1,  0,  1],
              [ 2,  3,  2,  1],
              [ 2,  3,  0,  3] ]

def tile(a, n, m, s, x, p)
  @count += 1
  h = m/2
  new_s = [s, s+h, s+h*n+h, s+h*n]
  new_x = [s+(h-1)*n+(h-1), s+(h-1)*n+h,  s+h*n+h, s+h*n+h-1]

  if p < 0
    pp = ((x-s) / n < h) ? ((x-s) % n < h) ? 0 : 1 \
                         : ((x-s) % n < h) ? 3 : 2   
  else
    pp = p
  end

  new_x.each_index{ |i| a[new_x[i]] = @count if i != pp }
  return if h == 1
  dir = DIRECTION[pp]
  if p < 0
    dir = dir.dup
    dir[pp] = -1
  end
  new_s.each_with_index { |e, i| tile(a, n, h, e, x, dir[i]) }
end

(puts "Usage: #$0 n"; exit) if (ARGV.size != 1 || ARGV[0].to_i <= 0)
n = 2 ** ARGV[0].to_i
a = Array.new(n*n)
x = rand(a.size)
a[x] = 'X'
@count = 0
tile(a, n, n, 0, x, -1)
format = "%#{2 + Math.log10(a.size).to_i}s"
a.each_with_index {|e, i| print(format % e); puts if (i+1)%(n) == 0}
