#--------------------------------------------------------------------
# Program : Solution for Ruby Quiz #33 Tiling Turmoil
# Author  : David Tran
# Date    : 2005-05-20
# Version : 1.0
#--------------------------------------------------------------------
def tile(a, n, m, s, x)
  @count += 1    
  h = m/2
  new_s = [s, s+h, s+h*n, s+h*n+h]
  new_x = [s+(h-1)*n+(h-1), s+(h-1)*n+h,  s+h*n+h-1, s+h*n+h] 
  p = ((x-s) / n < h) ? ((x-s) % n < h) ? 0 : 1 \
                      : ((x-s) % n < h) ? 2 : 3
  new_x.each_index{ |i| a[new_x[i]] = @count if i != p }
  return if h == 1
  new_x[p] = x
  new_s.each_with_index { |e, i| tile(a, n, h, e, new_x[i]) }
end

(puts "Usage: #$0 n"; exit) if (ARGV.size != 1 || ARGV[0].to_i <= 0)
n = 2 ** ARGV[0].to_i
@count = 0
a = Array.new(n*n)
x = rand(a.size)
a[x] = 'X'
tile(a, n, n, 0, x)
format = "%#{2 + Math.log10(a.size).to_i}s"
a.each_with_index {|e, i| print(format % e); puts if (i+1)%(n) == 0}
