#
# Raj Sahae
# RubyQuiz #117
# Frost Simulation
#
# USAGE:  ruby frost.rb [height] [width] [vapor_percentage]

class Fixnum
 def even?
   self%2 == 0
 end
 def odd?
   not self.even?
 end
 def prev
   self -1
 end
end

#The order ROWxCOL is kept throughout the program
# for any type of matrix/grid format.
class Torus
 attr_reader :width, :height
 attr_accessor :grid
   def initialize(row, col)
   raise "Width and Height must be even integers" unless row.even? and col.even?
   @width = col
   @height = row
   @grid = Array.new(row){Array.new(col)}
 end
 def [](row)
   @grid[row]
 end
 def []=(row, value)
   @grid[row] = value
 end
 def next_row(row)
   row.next == @height ? 0 : row.next
 end
 def next_col(col)
   col.next == @width ? 0 : col.next
 end
 def prev_row(row)
   row == 0 ? @height.prev : row.prev
 end
 def prev_col(col)
   col == 0 ? @width.prev : col.prev
 end
end

class FrostSimulation
 #Initialize with the number of rows and columns
 # and the percentage of the grid(an Integer from 0-100)
 # that should be vapor
 def initialize(rows, cols, percentage)

   @torus = Torus.new(rows, cols)
   @torus.grid.each{|row| row.collect!{|n| rand(99) < percentage ?(:vapor):(:vacuum)}}
   center = [rows/2, cols/2]
   @torus[center[0]][center[1]] = :ice

 end
 def display
   @torus.width.times{print '#'}; print "\n"
   @torus.grid.each do |row|
     row.each do |n|
       if n == :vapor        then print('.')
       elsif n == :vacuum then print(' ')
       elsif n == :ice       then print('*')
       end
     end
     print "\n"
   end
 end
 def extract_groups_at(tick)
   ptr = tick.even? ? [0, 0] : [1, 1]
   width, height = @torus.width/2, @torus.height/2
   #Neighborhood array is formatted counterclockwise from starting point
   #Eg. one element of neighborhood shows [top_left, bottom_left, bottom_right, top_right]
   groups = Array.new(width*height){Array.new(4)}
   groups.each_index do |index|
     groups[index][0] = @torus.grid[ptr[0]][ptr[1]] #set top_left
     ptr[0] = @torus.next_row(ptr[0])                #move pointer down a row
     groups[index][1] = @torus.grid[ptr[0]][ptr[1]] #set bottom_left
     ptr[1] = @torus.next_col(ptr[1])                 # move pointer over a col
     groups[index][2] = @torus.grid[ptr[0]][ptr[1]] # set bottom_right
     ptr[0] = @torus.prev_row(ptr[0])                # move pointer up a row
     groups[index][3] = @torus.grid[ptr[0]][ptr[1]] #set top_right
     ptr[1] = @torus.next_col(ptr[1])                 # move pointer over a col
     #if we are at the end of a row, move the pointer down 2 rows
     2.times{ptr[0] = @torus.next_row(ptr[0])} if index.next%width == 0
   end
 end
 def process_groups(groups)
   groups.each do |group|
     if group.include?(:ice)
       group.collect!{|n| n == :vapor ? :ice : n}
     else
       rand(100) < 51 ? group.unshift(group.pop) : group.push(group.shift)
     end
   end
 end
 def inject_groups(tick, groups)
   #this is the same algorithm as extraction
   ptr = tick.even? ? [0, 0] : [1, 1]
   width, height = @torus.width/2, @torus.height/2
   groups.each_index do |index|
     @torus.grid[ptr[0]][ptr[1]] = groups[index][0] #set top_left
     ptr[0] = @torus.next_row(ptr[0])                  #move pointer down a row
     @torus.grid[ptr[0]][ptr[1]] = groups[index][1]  #set bottom_left
     ptr[1] = @torus.next_col(ptr[1])                   # move pointer over a col
     @torus.grid[ptr[0]][ptr[1]] = groups[index][2]  # set bottom_right
     ptr[0] = @torus.prev_row(ptr[0])                  # move pointer up a row
     @torus.grid[ptr[0]][ptr[1]] = groups[index][3]  #set top_right
     ptr[1] = @torus.next_col(ptr[1])                   # move pointer over a col
     #if we are at the end of a row, move the pointer down 2 rows
     2.times{ptr[0] = @torus.next_row(ptr[0])} if index.next%width == 0
   end
 end
 def run
   tick = 0
   continue = true
   display
   while continue
     groups = inject_groups(tick, process_groups(extract_groups_at(tick)))
     display
     continue = @torus.grid.flatten.detect{|n| n == :vapor}
     tick = tick.next
     sleep(0.15)
   end
 end
end

if $0 == __FILE__
 rows = ARGV[0].nil? ? 24 : ARGV[0].to_i
 cols = ARGV[1].nil? ? 40 : ARGV[1].to_i
 percentage = ARGV[2].nil? ? 30 : ARGV[2].to_i
 sim = FrostSimulation.new(rows, cols, percentage)
 sim.run
end
