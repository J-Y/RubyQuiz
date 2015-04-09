#== Synopsis
#This is the solution to Ruby Quiz #107 described on http://www.rubyquiz.com/quiz107.html.
#
#== Usage
#   ruby word_search.rb
#   OR
#   ruby word_search.rb input_file
#
#== Author
#   Chunyun Zhao(chunyun.zhao@gmail.com)
#
class WordSearch
 attr_reader :found_coords

 def initialize(box)
   @box = box
   @height = @box.size
   @width = @box[0].size
 end

 def search_words(words)
   @found_coords=[]
   regexize_words(words)
   each_line do |line_coords|
     line_str = get_line_str(line_coords)
     words.each do |word|
       if line_str=~/#{word}/i
         offset = $~.offset(0)
         @found_coords |= line_coords[offset[0]...offset[1]]
       end
     end
   end
 end

 def display_words
   for x in 0...@height
     for y in 0...@width
       @found_coords.include?([x,y])? print(@box[x][y]):print('+')
       print ' '
     end
     puts
   end
 end

 private
 #Generates all possible lines(represented as arrays of coordinates) from @box , and
 #calls the block with the line coordinates.
 def each_line
   vertical_line_proc = lambda {|x, y| [x+1, y]}
   horizonal_line_proc = lambda {|x, y| [x, y+1]}
   backward_diagonal_line_proc = lambda {|x, y| [x+1, y+1]}
   forward_diagonal_line_proc = lambda {|x, y| [x+1, y-1]}

   lines = []
   #Genernates the lines starting with the top horizonal line
   for y in 0...@width
     lines << get_line_coords(0, y, &vertical_line_proc)
     lines << get_line_coords(0, y, &backward_diagonal_line_proc)
     lines << get_line_coords(0, y, &forward_diagonal_line_proc)
   end
   #Genernates the lines starting with the leftmost and rightmost vertical lines
   for x in 0...@height
     lines << get_line_coords(x, 0, &horizonal_line_proc)
     lines << get_line_coords(x, 0, &backward_diagonal_line_proc)
     lines << get_line_coords(x, @width-1, &forward_diagonal_line_proc)
   end
   lines.each{|line_coords|yield line_coords; yield line_coords.reverse}
 end

 #Generates the line starting with coordinate [x,y]. It calls the block to find the
 #next position in the line. It can be used to generate snake lines if necessary.
 def get_line_coords(x, y)
    line = [[x,y]]
    loop do
      next_x, next_y = yield x, y
      @box[next_x] && @box[next_x][next_y] ? line << [next_x, next_y] : break
      x, y = next_x, next_y
    end
    line
 end

 #Gets the string represented by an array of coordinates.
 def get_line_str(coords)
   line_str = ''
   coords.each{|x,y| line_str << @box[x][y]}
   line_str
 end

 #Replaces ? and * with \w? and \w* in each word so that it could be used
 #as the regex to support wildcard letter matching.
 def regexize_words(words)
   words.each {|word|word.gsub!(/(\?|\*)/, '\w\1')}
 end
end

box = []
width = nil
while line=gets
 break if line.strip.empty?
 row = line.split
 raise "The width of all the rows must be equal!" if !width.nil? and width != row.size
 width = row.size
 box << row
end
raise "You need at least enter one row of letters!" if box.empty?
words = gets.split
raise "You need at least enter one word!" if words.empty?

ws = WordSearch.new(box)
ws.search_words(words)
ws.display_words
