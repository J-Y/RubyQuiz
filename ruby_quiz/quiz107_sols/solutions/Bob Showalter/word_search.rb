# RubyQuiz Word Search (107)
# Bob Showalter

class WordSearch

 class Board < Array

   def to_s
     collect {|s| s.split(//).join(' ')}.join("\n")
   end

 end

 attr_reader :board, :solution

 # creates a new, empty solver
 def initialize
   @board = Board.new
   @solution = Board.new
 end

 # resets the solution
 def reset
   @solution.clear
   @board.each {|row| @solution << row.gsub(/./, '+')}
 end

 # checks that the board contains only letters and that it has a uniform
 # rectangular shape
 def validate
   @board.size > 0 or raise "Board has no rows"
   @board.grep(/[^A-Z]/).empty? or raise "Board contains non-letters"
   w = @board.collect {|row| row.size}.uniq
   w.size == 1 or raise "Board rows are not all the same length"
   w.first > 0 or raise "Board has no columns"
 end

 # parses the board by reading lines from io until a blank line (or EOF)
 # is read.
 def parse(io = ARGV)
   @board.clear
   while line = io.gets
     line = line.strip.upcase
     break if line == ''
     @board << line
   end
   validate
   reset
 end

 # search for word. returns number of times found.  solution is updated with
 # all occurences.
 def search(word)
   found = 0
   0.upto(board.size-1) do |y|
     0.upto(board[y].size-1) do |x|
       [-1, 0, 1].each do |dy|
         [-1, 0, 1].each do |dx|
           next if dx == 0 and dy == 0
           found += 1 if search_for(word.strip.upcase, x, y, dx, dy)
         end
       end
     end
   end
   found
 end

 # search for word in board starting at position (x,y) and moving in direction
 # (dx,dy). returns true if found, false if not found.
 def search_for(word, x, y, dx, dy)
   return false if x < 0 or x >= board.first.size or y < 0 or y >= board.size
   return false if board[y][x] != word[0]
   prev = solution[y][x]
   solution[y][x] = board[y][x]
   return true if word.length <= 1
   found = search_for(word[1,word.length-1], x + dx, y + dy, dx, dy)
   solution[y][x] = prev unless found
   found
 end

 # creates a new puzzle by parsing the board from io. see WordSearch#parse
 def self.parse(io = ARGF)
   obj = new
   obj.parse(io)
   obj
 end

 def to_s
   solution.to_s
 end

end

# parse the board first
p = WordSearch.parse

# parse the words until a blank line is read
words = []
while line = ARGF.gets
 line = line.strip.upcase
 break if line == ''
 words += line.gsub(',', ' ').split
end

# submit each word and show how many times it was found
for word in words.sort.uniq
 n = p.search(word)
 puts word + ' was ' + (n == 0 ? 'not found' : n == 1 ? 'found once' : "found #{n} times")
end

# show the solution
puts p
