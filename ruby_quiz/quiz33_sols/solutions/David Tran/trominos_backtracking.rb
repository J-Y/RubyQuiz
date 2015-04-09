# ------------------------------------------------------------------------------
# Program : Solution for Ruby Quiz Tiling Turmoil (#33)
# Author  : David Tran
# Date    : 2005-05-23
# Vesion  : Use Simple Backtracking to compute all solutions
# Note    : Simple backtracking, no use any math theorem or 
#           pattern analyse. It is not efficient at all!
#           BTW. The total solution for 8x8 and missing cell at [0,0] is 30355.
# ------------------------------------------------------------------------------

def help
  puts "Usage: #$0 n [sol]"
  puts "  Tiling Turmoil for board of 2^n x 2^n cases with one random
missing case"
  puts "  sol: Optional."
  puts "       Number solution desire. Default value equals 1."
  puts "       Equals to zero : Compute total solution number without
print solutions."
  puts "       Less then zero : Print all possible solutions."
  exit
end

# To make sure back tracking all possible solutions, the tiling order
is important.
# This program will tile trimino from top to bottom and left to right.
# 
# So, the 4 possible L-tromino will have this relation coordination (x, y):
TROMINOS = [ [ [1, 0], [0, 1] ],    # o*
                                    # *
                                    # 
             [ [1, 0], [1, 1] ],    # o*
                                    #  *
                                    #  
             [ [0, 1], [1, 1] ],    # o
                                    # **
                                    # 
             [ [0, 1], [-1,1] ] ]   #  o
                                    # **


def tile_next(a, n, count)
  (0...n).each do |y|
    (0...n).each do |x|
      next if a[y][x]
      TROMINOS.each do |tromino|
        x1 = x + tromino[0][0]
        y1 = y + tromino[0][1]
        x2 = x + tromino[1][0]
        y2 = y + tromino[1][1]
        next if ( x1 < 0 || x1 >= n || 
                  y1 < 0 || y1 >= n ||
                  x2 < 0 || x2 >= n ||
                  y2 < 0 || y2 >= n ||
                  a[y1][x1] || a[y2][x2] )
        a[y][x] = a[y1][x1] = a[y2][x2] = count 
        tile_next(a, n, count+1)
        a[y][x] = a[y1][x1] = a[y2][x2] = nil  # back tracking
      end
      return
    end
  end
  print_solution(a)
end


def print_solution(a)
  @solutions += 1
  if @show_solution
    puts "solution ##@solutions" 
    a.each {|row| puts row.inject('') {|s, e| s + e.to_s.rjust(@digits+1) } }
    puts
  end
  exit if @num_solutions != nil && @solutions >= @num_solutions
end


help if ARGV.size <= 0 || ARGV[0].to_i <= 0
n = 2 ** ARGV[0].to_i
option = ARGV[1] ? ARGV[1].to_i : 1
@num_solutions = (option <= 0) ? nil : option
@show_solution = (option != 0)
@digits = (n*n).to_s.size
@solutions = 0
a = Array.new(n) { Array.new(n) }
a[rand(n)][rand(n)] = 'X'
tile_next(a, n, 1)
puts "Total possible solutions = #@solutions" if @num_solutions.nil?
