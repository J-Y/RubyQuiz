#
# Justin Ethier
# 
# July 30th 2007
# 
# Solution to Ruby Quiz 132: Crossword Solver
# http://www.rubyquiz.com/quiz132.html
# 

# This class defines a crossword puzzle board
# and encapsulates related methods
class CrosswordBoard
  def initialize(template, width)
    @template = template.upcase
    @width = width
  end

  # Adds a word to the board. 
  # Returns true on success or false if word could not be added
  def add(word, row, col, orient)
    if able_to_place?(word, row, col, orient)
      put_contents(word, row, col, orient)
      return true
    end
    
    return false
  end
    
  # Remove a word from the puzzle, leaving any characters that 
  # are still in use by other words on the puzzle.
  def remove(word, row, col, orient)
    loc = BoardLocation.from_pt(row, col, @width)

    for i in 0..word.length - 1
      # Remove current character
      if @template[loc.get_raw(loc.row, loc.col)] != nil
        next_chr = @template[loc.get_raw(loc.row, loc.col)].chr
        
        if next_chr != nil and next_chr != "#"
          # If this char is used by another word, then it must stay
          if (not is_chr_used_by_another_word?(loc, orient))
            next_chr = "_"
          end
  
          # Update the board
          @template[loc.get_raw(loc.row, loc.col)] = next_chr
        end
      end
      
      # Move to the next character
      if (orient == :horz)
        loc.col = loc.col + 1
      else
        loc.row = loc.row + 1
      end      
    end

  end
  
  # Determine if the character at a given location is
  # used by another word on the board
  # Inputs: Location
  #         Orientation - The orientation the letter is currently used at,
  #                       this method will see if a word in the other orientation
  #                       (horzontal or vertical) uses it.
  def is_chr_used_by_another_word?(loc, orient)
    # Check other orientation
    if orient == :horz
      if (loc.get_raw(loc.row + 1, loc.col) != nil and
          @template[loc.get_raw(loc.row + 1, loc.col)]     != nil and
          @template[loc.get_raw(loc.row + 1, loc.col)].chr != "#" and
          @template[loc.get_raw(loc.row + 1, loc.col)].chr != "_") or
         (loc.get_raw(loc.row - 1, loc.col) != nil and
          @template[loc.get_raw(loc.row - 1, loc.col)]     != nil and
          @template[loc.get_raw(loc.row - 1, loc.col)].chr != "#" and
          @template[loc.get_raw(loc.row - 1, loc.col)].chr != "_")
         return true
      end
    else
      if (loc.get_raw(loc.row, loc.col + 1) != nil and
          @template[loc.get_raw(loc.row, loc.col + 1)]     != nil and
          @template[loc.get_raw(loc.row, loc.col + 1)].chr != "#" and
          @template[loc.get_raw(loc.row, loc.col + 1)].chr != "_") or
         (loc.get_raw(loc.row, loc.col - 1) != nil and 
          @template[loc.get_raw(loc.row, loc.col - 1)]     != nil and
          @template[loc.get_raw(loc.row, loc.col - 1)].chr != "#" and
          @template[loc.get_raw(loc.row, loc.col - 1)].chr != "_")
         return true
      end
    end
    
    return false
  end
  
  # Determine if we are able to place a word at a given location with a
  # specific orientation. Basically makes sure that the word being placed
  # matches any letters already placed on the board
  def able_to_place?(word, row, col, orient)
    contents = get_contents(row, col, orient, word.size)
    loc = BoardLocation.from_pt(row, col, @width)

    # Make sure word matches any letters on the board, and does 
    # not overlap invalid characters or the end of the board
    for i in 0..contents.length - 1
      if (contents[i] == nil) or
         (contents[i].chr == "#") or
         (contents[i].chr != "_" and contents[i] != word[i])
         return false
      end
    end
    
    return true
  end
  
  # Get raw letters at the given board vector
  def get_contents(row, col, orient, length)
    contents = []
    loc = BoardLocation.from_pt(row, col, @width)
    
    for i in 0..length-1
      if (orient == :horz)
        index = loc.get_raw(loc.row, loc.col + i)
      else
        index = loc.get_raw(loc.row + i, loc.col)
      end
      
      if index != nil
        contents.push(@template[index].chr)
      end
    end
    
    contents.join
  end
  
  # Put raw letters on to the board
  def put_contents(word, row, col, orient)
    loc = BoardLocation.from_pt(row, col, @width)
    
    for i in 0..word.size-1
      if (orient == :horz)
        @template[loc.get_raw(loc.row, loc.col + i)] = word[i].chr
      else
        @template[loc.get_raw(loc.row + i, loc.col)] = word[i].chr
      end
    end
  end
  
  # Print board to the console
  def print
    for i in 0..@template.size / @width
      puts @template.slice(i * @width, @width).split("").join(" ")
      puts ""
    end
  end
  
  private :put_contents
  attr_reader :template, :width
end

# Defines a location on a puzzle board
# Basically, a 2 dimensional board is stored in memory as a 
# single-dimension array. This class enables that array to be
# indexed in 2 dimensions.
class BoardLocation
  def initialize(raw, width)
    @width = width
    @row = raw / @width
    @col = raw % @width
  end

  # Create a board location object from a row/col/width
  # Serves as an alternative to the constructor
  def BoardLocation.from_pt(row, col, width)  
    return BoardLocation.new(row * width + col, width)
  end
  
  # Return the raw location index
  def raw
    return @row * @width + @col
  end
  
  # Calculate a raw location index from the given row/col points
  def get_raw(row, col)
    if row < 0 or
       col < 0 or 
       col >= @width #Enhancement: validate height
      return nil
    end

    return row * @width + col
  end
  
  attr_accessor :row, :col
end

# Defines a space on a puzzle board
class BoardSpace
  def initialize(row, col, orient, length)
    @row = row
    @col = col
    @orient = orient
    @length = length
  end
  
  attr_reader :row, :col, :orient, :length
end

# Defines methods used to solve a crossword puzzle
class CrosswordSolver
  def initialize(board)
     @board = board
  end
 
  # Solve the current puzzle board using the given dictionary of words
  def solve(dict)
    # Find the next space to add at
    row, col, orient, length = find_next_free_space
    if (row != nil)
      # find the next word that could fit in the space
      for i in 0..dict.size - 1
        if dict[i].size == length and
          @board.add(dict[i], row, col, orient)
          
          # Use a copy of the dict with the word removed, to prevent reusing a word
          dict_trunc = Array.new(dict)
          dict_trunc.delete_at(i)
          
          # Recurse
          if solve(dict_trunc)
            # Recursion successful, we have solved the puzzle
            return true
          else
            # Recursion failed, need to back up and try other words here
            @board.remove(dict[i], row, col, orient)
          end
        end
      end
      
      # Tried all words at this recursion level and none worked
      return false 
    end
    
    # No free space found, so we must be at the end of the puzzle
    return true 
  end  
  
  # Finds the next empty square on the puzzle
  # Returns the location of that square, or nil if none
  def find_next_underscore
    for i in 0..@board.template.size - 1
      if (@board.template[i].chr == "_")
        return BoardLocation.new(i, @board.width)
      end
    end
    
    return nil
  end
  
  # Find the next free space on the puzzle board,
  # Returns the properties (length, orientation, etc) of that space
  def find_next_free_space
    row = nil
    col = nil
    orient = nil
    length = 0
    
    # Find the next empty space
    loc = find_next_underscore
    if (loc != nil)
      # Find orientation, only need to check to right or down, since board is searched linearly
      index = loc.get_raw(loc.row, loc.col + 1)
      next_chr = index == nil ? nil : @board.template[index]
      if next_chr != nil and 
         next_chr.chr != "#"
        orient = :horz
      else
        orient = :vert
      end
      
      # Back up, in case there are already letters on the board
      while ( loc.raw > 0 and
             (loc.col > 0 and orient == :horz) or (loc.row > 0 and orient == :vert) and
             @board.template[loc.raw] != nil and
             @board.template[loc.raw].chr != "#")
        if (orient == :horz)
          loc.col = loc.col - 1
        else
          loc.row = loc.row - 1
        end             
      end 
      
      # Find length of the opening
      loc_raw = loc.raw
      while (loc_raw != nil and
             @board.template[loc_raw] != nil and
             @board.template[loc_raw].chr != "#")
        length = length + 1
        
        if (orient == :horz)
          loc_raw = loc.get_raw(loc.row, loc.col + length)
          if length == @board.width
            break
          end
        else
          loc_raw = loc.get_raw(loc.row + length, loc.col)        
        end
      end
      
      # Populate return vars
      row = loc.row
      col = loc.col      
      #length = length - 1
    end
    
    return row, col, orient, length
  end
  
  # Read a template from file
  def CrosswordSolver.read_template_from_file(filename)
    template = ""
    width = 0
    
    fp = File.new(filename)
    for line in fp.readlines
      if line.strip.size > 0
        width = line.size / 2 if width == 0
        template = template + line.split(" ").flatten.join
      end
    end
    fp.close
    
    CrosswordBoard.new(template, width)
  end
  
  # Read a dictionary from file
  def CrosswordSolver.read_dictionary_from_file(filename)
    dict = []
     
    fp = File.new(filename)
    for line in fp.readlines
      dict.push(line.strip.upcase)
    end
    fp.close
    
    # Randomize the order of words in the dictionary
    CrosswordSolver.shuffle_array(dict)
  end  

  # Randomizes the order of items in the given array
  def CrosswordSolver.shuffle_array(array)
    for i in 0..array.size - 1
      shuffle_index = rand(array.size)
      array[i], array[shuffle_index] = array[shuffle_index], array[i]
    end  
    array
  end
end

if ARGV.size != 2
  puts "Usage: crossword_solver.rb dictionary_file template_file"
else
  # Read dict from file
  dict = CrosswordSolver.read_dictionary_from_file(ARGV[0])
  
  # Read template from file
  cb = CrosswordSolver.read_template_from_file(ARGV[1])

  # Solve the puzzle
  @c = CrosswordSolver.new(cb)
  @c.solve(dict)
  cb.print  
end
