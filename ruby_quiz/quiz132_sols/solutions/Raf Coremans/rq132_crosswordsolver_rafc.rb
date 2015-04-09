#!/usr/bin/ruby -w

# rq132_crosswordsolver_rafc.rb
# Solution to http://www.rubyquiz.com/quiz132.html
# By Raf Coremans
#
# Usage: ./rq132_crosswordsolver_rafc.rb <crossword>
#
# Example:
# echo '
# _ _ _ _ _
#
# _ # _ # _
#
# _ _ _ _ _
#
# _ # _ # _
#
# _ _ _ _ _
# ' | ./rq132_crosswordsolver_rafc.rb


#"Word" models a region in the crossword puzzle: a contiguous array of at least
#two cells, all going down or all going across, and for which at least one cell
#has to be filled in.
#(:x, :y) is the coordinate of the beginning of the Word
class Word
  include Enumerable
  attr_reader :x, :y, :direction, :size

  VALID_DIRECTIONS = [:across, :down]
  DX = { :across => 1, :down => 0}
  DY = { :across => 0, :down => 1}

  def initialize( x, y, direction, size)
    raise ArgumentError.new( "Invalid direction: [#{direction}]") unless
      VALID_DIRECTIONS.include?( direction)

    @x = x
    @y = y
    @direction = direction
    @size = size
  end

  #Yields the coordinate of each cell in the Word
  def each
    dx = DX[@direction]; dy = DY[@direction]
    x = @x; y = @y
    @size.times do
      yield x, y
      x += dx; y += dy
    end
  end
end


class Crossword
  attr_reader :dict

  def initialize( puzzle, dict)
    build_dictionary( dict)
    read_puzzle( puzzle)
    find_words
  end


  def solve( find_all = false, &block)
    determine_strategy( find_all, &block)
    @steps.first.perform( self) #Fire off the actual solving
  end


  #Reads the puzzle
  def read_puzzle( puzzle)
    lines = puzzle.map{ |line| line.upcase.gsub( /\s+/, '')}.reject{ |line| line.empty?}

    @width = lines.map{ |line| line.size}.max
    @height = lines.size

    @board = Array.new( @height){ Array.new( @width, '#')}
    lines.each_with_index do |line, y|
      line.split( //).each_with_index do |char, x|
        self[x, y] = char
      end
    end
  end #def read_puzzle


  #Find all Words: all regions in the crossword puzzle for which there is
  #something to fill in
  def find_words
    @words = []

    #Across:
    @height.times do |y|
      x = 0
      while x < @width
        size = word_size_at( x, y, :across)
        #We're only interested in Words of length 2 or more:
        if size > 1
          potential_word = Word.new( x, y, :across, size)
          wv = value_of_word( potential_word)
          #We're only interested in Words for which there is at least still
          #one cell to fill in:
          @words << potential_word if value_of_word( potential_word) !~ /^[A-Z]*$/
          x += wv.size
        end
        x += 1
      end
    end

    #TODO: DRY...
    #Down:
    @width.times do |x|
      y = 0
      while y < @height
        size = word_size_at( x, y, :down)
        #We're only interested in Words of length 2 or more:
        if size > 1
          potential_word = Word.new( x, y, :down, size)
          wv = value_of_word( potential_word)
          #We're only interested in Words for which #there is at least still
          #one cell to fill in:
          @words << potential_word if value_of_word( potential_word) !~ /^[A-Z]*$/
          y += wv.size
        end
        y += 1
      end
    end
  end #def find_words


  #Is there a word at the given position and direction of the crossword puzzle,
  #and if so of what size?
  def word_size_at( x, y, direction)
    dx = Word::DX[direction]
    dy = Word::DY[direction]

    size = 0
    while '#' != self[x, y]
      size += 1
      x += dx; y += dy
    end

    size
  end


  #Given the name of a file, extracts words from it and builds up a dictionary
  #with them
  def build_dictionary( dict)
    @dict = File.readlines( dict).
      map{ |w| w.chomp.upcase.split}.
      flatten.
      reject{ |w| w !~ /^[A-Z]+$/}. #We don't want words containing non-letters
      uniq.
      sort_by{ rand }.              #Spec: "Each run of the program
                                    #with big enough dictionary should give a
                                    #different solution"
      inject( {}) do |h, w|         #Divide dictionary up according to word-length;
        ( h[w.size] ||= []) << w    #this will speed up things later
        h
      end
    #Now @dict[2] the array of all two-letter words, @dict[3] of all
    #three-letter words, etc.
  end #def build_dictionary


  #Get char that is at position ( x, y) of the crossword puzzle
  def []( x, y)
    return '#' unless ( 0...@width).include?( x) 
    return '#' unless ( 0...@height).include?( y) 

    @board[y][x] #This weird mapping makes Crossword#to_s much easier to implement
  end


  #Set position ( x, y) of the crossword puzzle to char
  def []=( x, y, char)
    @board[y][x] = char
  end


  #Get the value of a Word within the current state of the Crossword: a String
  #containing '_' for each letter that still must be filled in
  def value_of_word( word)
    word.map{ |x, y| self[x, y]}.join
  end


  #Fill in a Word with a given value
  def fill_in_word( word, value)
    track = []
    word.each_with_index do |coordinate, i|
      x, y = *coordinate
      #Only fill in a cell if it isn't yet filled in:
      if self[x, y] !~ /[A-Z]/
        self[x, y] = value[i, 1]
        track << [x, y]
      end
    end
    
    #Returns an array of cells that actually have been filled in, so as to be
    #able to backtrack later
    track
  end


  #Backtrack: remove the value of a Word previoulsy filled in
  def backtrack( track)
    track.each do |x, y|
      self[x, y] = '_'
    end
  end


  #The number of freedoms for a Word: a measure for the number of possibilities
  #there are to complete this Word, given the state that the (partially filled
  #in) crossword is in at this point in time
  def freedoms_of_word( word)
    wv = value_of_word( word)
    number_of_known_letters = wv.scan( /[A-Z]/).size

    #Number of freedoms: the number of words within our dictionary having the
    #same length, divided by 26 for every letter that is already known
    @dict[word.size].size.to_f / ( 26 ** number_of_known_letters)
  end


  #Determine the Steps needed to solve the crossword puzzle
  def determine_strategy( find_all, &block)
    @steps = []

    words = @words.dup

    tracks = []
    #Find the Word that at this point in time has the least freedoms, and fill
    #that in first. This makes that the solution builds on words that are already
    #partially known
    while !words.empty?
      word_to_fill_in = words.sort_by{ |word| freedoms_of_word( word)}.first
      @steps << ChooseStep.new( word_to_fill_in)

      #Fill in the word with a dummy value; we have to fill it in with
      #something because the level of filled-in-ness determines which word we
      #will want to fill in next:
      wv = value_of_word( word_to_fill_in)
      tracks << fill_in_word( word_to_fill_in, 'X' * wv.size)

      words.delete( word_to_fill_in)
    end

    #When that's done, we have our solution:
    @steps << FinishStep.new(find_all, &block)

    #Now our crossword is filled with dummy values, so, clean-up:
    tracks.each{ |track| backtrack( track)}

    @steps.each_with_index { |step, i| step.next_step = @steps[i + 1] }
    
    #@steps.each_with_index { |step, i| puts "#{i + 1}. #{step}" }
  end #def determine_strategy


  def to_s
    @board.map{ |a| a.join}.join( "\n")
  end
end #class Crossword


#Divide the problem in steps; solve each step, backtracking as needed.
#Based on Eric I.'s solution to Ruby quiz 128 (http://rubyquiz.com/quiz128.html)
class Step
  attr_writer :next_step
end


#ChooseStep: for a given Word, choose a value that fits in with the state of
#the (partially filled in) crossword at this point in time
class ChooseStep < Step
  def initialize( word)
    @word = word
  end

  def to_s
    "Choose a word for (#{@word.x}, #{@word.y}), #{@word.direction.to_s}"
  end

  def perform( crossword)
    #Try every possible solution that fits in this Word at this point in time:
    wv = crossword.value_of_word( @word)             # =>  '__R_Y_'
    re = Regexp.new( '^' + wv.gsub( /_/, '.') + '$') # => /^..R.Y.$/
    words_to_choose_from = crossword.dict[wv.size].grep( re)

    cont = true
    words_to_choose_from.each do |w|
      #Try a word:
      track = crossword.fill_in_word( @word, w)

      #And see if it works out with the rest of the crossword puzzle:
      cont = @next_step.perform( crossword)
      break unless cont

      #Word was no good; erase it:
      crossword.backtrack( track)
    end
    cont
  end
end


#FinishStep: if we've arrived here, the whole crossword has been filled in with
#words from the dictionary
class FinishStep < Step
  def initialize( find_all = false, &block)
    @find_all = find_all
    @callback = block
  end

  def to_s
    "Done!"
  end

  def perform( crossword)
    @callback.call( crossword)
    @find_all #Determines whether to stop or continue at first found solution
  end
end


##########################
#Main:
##########################

c = Crossword.new( ARGF, '/usr/share/dict/words')

t_start = Time.now
c.solve{ |solution| puts solution}
puts "(Solution found in #{Time.now - t_start} seconds.)"