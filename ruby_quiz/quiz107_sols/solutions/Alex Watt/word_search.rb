class Array
 def positions(value)
   positions = []
   each_index { |i| positions << i if self[i] == value }
   positions
 end
end

class WordSearch
 def initialize(wordSearch,*words)
   @wordSearch = wordSearch
   @rows = @wordSearch.split(/\s+/).delete_if { |row| row == "" }
   @letters = @wordSearch.gsub(/\s+/,"").split(//)
   @words = *words
   @letterPositions = []
   @rowLength = @rows[0].length
   @numberOfRows = @rows.length
 end
 def solve
   @words.each { |word|
     @letters.positions(word[0].chr).each { |letterPos|
       tooCloseToRight = (@rowLength - (letterPos % @rowLength)) < word.length
       tooCloseToLeft = letterPos % @rowLength < word.length
       tooCloseToTop = (letterPos / @rowLength) < word.length
       tooCloseToBottom = (@numberOfRows - (letterPos / @rowLength).to_i) < word.length
       search(word,letterPos,1) unless tooCloseToRight                                                        # to the right
       search(word,letterPos,-1) unless tooCloseToLeft                                                        # to the left

       search(word,letterPos,-(@rowLength - 1)) unless tooCloseToTop or tooCloseToRight       # top right diagonal
       search(word,letterPos,-(@rowLength)) unless tooCloseToTop                                      # above
       search(word,letterPos,-(@rowLength + 1)) unless tooCloseToTop or tooCloseToLeft       # top left diagonal

       search(word,letterPos,@rowLength + 1) unless tooCloseToBottom or tooCloseToRight     # bottom right diagonal
       search(word,letterPos,@rowLength) unless tooCloseToBottom                                     # below
       search(word,letterPos,@rowLength - 1) unless tooCloseToBottom or tooCloseToLeft       # bottom left diagonal
     }
   }
 end
 def search(word,pos,direction)
   positions = []
   for i in (0...word.length)
     positions << (pos + direction*i) if word[i].chr == @letters[pos + direction*i] or word[i].chr == "*" or @letters[pos + direction*i] == "*"
   end
   @letterPositions << positions if positions.length == word.length
 end
 def printWordSearch
   @letterPositions.flatten!
   @letters.each_index { |i|
     character = @letterPositions.include?(i) ? @letters[i] : "+"
     print character
     if (i + 1) % @rows[0].length == 0
       print "#{i/@rows[0].length + 1}".rjust(6)
       puts
     end
   }
 end
end

wordSearch = []
loop do
 row = gets.chomp
 wordSearch << row
 break if row == ""
end
wordSearch.delete_at(-1)
words = gets.chomp.upcase.split(/\s*,\s*/)
w = WordSearch.new(wordSearch.join("\n"),words)
w.solve
w.printWordSearch
