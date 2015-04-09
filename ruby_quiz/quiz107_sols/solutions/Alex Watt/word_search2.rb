class Wordsearch
 DIRECTIONS = [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,-1],[-1,1]]
 def initialize(wordsearch,words)
   @words = words
   @rows = wordsearch.split(/\s+/).delete_if { |row| row == "" }
   @points = {}
   @letterPositions = []
   @rows.each_with_index do |row,y|
     row.split(//).each_with_index do |letter,x|
       @points[[x,y]] = letter
     end
   end
 end
 def solve
   @words.each { |word| search(word) }
 end
 def printWordsearch
   @rows.each_with_index do |row,y|
     row.split(//).each_with_index do |letter,x|
       print @letterPositions.include?([x,y]) ? letter : "+"
     end
     puts
   end
 end

 private

 def search(word)
   points(word[0].chr).each do |point|
     DIRECTIONS.each do |direction|
       possiblePoints = [point]
       point2 = point
       for i in (1...word.length)
         if checkNext(point2,word[i].chr,direction) or word[i].chr == "*" or @points[(point2.to_p + direction.to_p).to_a] == "*" # wildcard character = *
           possiblePoints.push((point2 = (point2.to_p + direction.to_p).to_a))
         end
       end
       @letterPositions += possiblePoints if possiblePoints.length == word.length
     end
   end
 end
 def points(aLetter)
   points = []
   @points.each do |point,letter|
     points.push(point) if aLetter == letter
   end
   points
 end
 def checkNext(point,letter,direction)
   @points[(point.to_p + direction.to_p).to_a] == letter
 end
end

class Array
 def to_p
   Point.new(self[0].to_i,self[1].to_i)
 end
end

class Point
 attr_reader :x,:y
 def initialize(x,y)
   @x,@y = x,y
 end
 def +(point)
   Point.new(@x + point.x,@y + point.y)
 end
 def to_a
   [@x,@y]
 end
end

wordsearch = ""
loop do
 row = gets.chomp
 wordsearch += row + "\n"
 break if row == ""
end
words = gets.chomp.split(/\s*,\s*/).map { |word| word.upcase.gsub(/\s/,"") }
w = Wordsearch.new(wordsearch.upcase,words)

w.solve
w.printWordsearch
