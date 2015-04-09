#--------------------------------------------------------------------
# Program : Solution for Ruby Quiz #33 Tiling Turmoil
# Author  : David Tran
# Date    : 2005-05-20
# Version : Using 4 color codes
#--------------------------------------------------------------------
def tile(a, n, m, s, x)
  h = m/2
  new_s = [s, s+h, s+h*n, s+h*n+h]
  new_x = [s+(h-1)*n+(h-1), s+(h-1)*n+h,  s+h*n+h-1, s+h*n+h] 
  around_tile = [new_x[0]%n == 0      ? nil : new_x[0]-1, 
                 new_x[0] < n         ? nil : new_x[0]-n,
                 new_x[1] < n         ? nil : new_x[1]-n,
                 (new_x[1]+1)%n == 0  ? nil : new_x[1]+1,
                 new_x[2]%n == 0      ? nil : new_x[2]-1,
                 new_x[2]/n + 1 >= n  ? nil : new_x[2]+n,
                 new_x[3]/n + 1 >= n  ? nil : new_x[3]+n, 
                 (new_x[3]+1)% n == 0 ? nil : new_x[3]+1]

  p = ((x-s)/ n < h) ? ((x-s)% n < h) ? 0 : 1 \
                     : ((x-s)% n < h) ? 2 : 3

  around_tile[p*2, 2] = new_x[p]
  (1..4).each do |color| 
    use = false
    around_tile.each do |i|
      next if i.nil?
      (use = true; break) if a[i] == color
    end
    if (!use)
      new_x.each_index{ |i| a[new_x[i]] = color if i != p }
      break;
    end
  end

  return if h == 1
  new_x[p] = x
  new_s.each_with_index { |e, i| tile(a, n, h, e, new_x[i]) }
end

(puts "Usage: #$0 n"; exit) if (ARGV.size != 1 || ARGV[0].to_i <= 0)
n = 2 ** ARGV[0].to_i
a = Array.new(n*n)
x = rand(a.size)
a[x] = 0
tile(a, n, n, 0, x)
colorCode = [' ', '*', 'o', '+', '-']
a.each_with_index { |e, i| print(" #{colorCode[e]}"); puts if (i+1)%n == 0 }
