# create a each_chr method
class String
 def each_chr
  self.each_byte { |b| yield b.chr }
 end
end

class Puz
 DIRECTIONS = [[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1],[0,-1],[1,-1]]

 # puzzle - array of strings (one for each line)
 # word_list - array for words to look for
 def initialize(puzzle, word_list)
  @puzzle = puzzle
  @word_list = word_list

  # get dimention of the board
  @x,@y = @puzzle[0].length-1, @puzzle.length-1

  # create an empty result board
  @result = Array.new(@y+1)
  0.upto(@y) { |i| @result[i] = String.new("+"*(@x+1)) }
 end

protected

 # return cursor to the next position in direction
 def gonext(x,y,d)
  x+=d[0]; y+=d[1]
  x = 0 if x > @x;  x = @x if x < 0
  y = 0 if y > @y; y = @y if y < 0
  [x,y]
 end

 # writes a word into the @result container
 def write_result(word, x,y, direction)
   word.each_chr do |c|
    @result[y][x] = c
    x,y = gonext(x,y, direction)
   end
 end

 # yields all possible cursor positions of the board
 def each_position
   0.upto(@y) { |y| 0.upto(@x) { |x| yield x,y }}
 end

 def char_match(char, x, y)
   return true if char == '?'           # allow wildcard '?'
   @puzzle[y][x].chr == char
 end

 # finds a given word on a position in a specific direction
 def find_in_direction(word, x, y, d)
   word.each_chr do |c|
    return false if !self.char_match(c, x, y)
    x,y = gonext(x,y,d)
   end
  true
 end

 # finds a word on a position
 def find(word, x, y)
   DIRECTIONS.each do |d|
       write_result(word, x,y,d) if find_in_direction(word, x,y, d)
   end
 end

public

 def resolve
   @word_list.each do |word|
     each_position { |x,y| find(word, x, y) }
   end
   return (@result.join("\n"))
 end
end

board = []
while true do
 inp = STDIN.gets.strip
 if inp.length > 0 then board << inp else break end
end

puts Puz.new(board, STDIN.gets.split(',').collect{ |w| 
w.strip.upcase}).resolve
