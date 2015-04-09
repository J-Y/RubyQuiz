class WordSearch
  attr_reader :rows, :row_length, :words
  
  def initialize(input)
    input_lines = input.to_a
    
    raise "At least three lines must be entered" if input_lines.size < 3
    
    @words = input_lines.pop.downcase.gsub(/\s/, '').split(',')
    raise "Words need to be specified" if @words.empty?
    
    input_lines.pop # remove empty line

    raise "No rows provided" if input_lines.empty?

    @chars = {} # starting points
    row_index = -1
    @rows = Array.new(input_lines.size) do
      row_index += 1
      col_index = -1
      input_lines.shift.strip.downcase.scan(/./).map do |char| 
        col_index += 1
        field = Field.new char, row_index, col_index, self
        (@chars[char] ||= []) << field
        field
      end
    end

    @row_length= rows.first.size
    raise "All rows need to have the same number of columns" if @rows.any? {|r| r.size != @row_length}
  end
  
  def field(row_idx, col_idx)
    @rows[row_idx][col_idx]
  end
  
  def solve
    fields = @words.collect do |word| 
      result = find_word(word) || find_word(word.reverse)
      raise "Word #{word} not found" unless result
      result
    end.flatten.uniq
    
    all_fields = Array.new(rows.size) {"+"*row_length}
    fields.each do |field|
      all_fields[field.row_idx][field.col_idx] = field.value
    end
    (all_fields.join("\n")+"\n").upcase
  end
  
  private 
  def find_word(word, try_field = nil, visited_fields = [])
    visited_fields = visited_fields.dup
    
    # Iter over the hash associated with characters to find starting points
    if try_field.nil? 
      first_char = word[0..0]
      starting_points = @chars[first_char]
      return false unless starting_points
      
      starting_points.each do |field|
        result = find_word(word, field)
        return result if result
      end
      return false

    else # find_word with a starting point called
      
      visited_fields << try_field    

      found_word = visited_fields.collect{|f|f.value}.join

      # check partial match wrt wildcards
      search_word = word[0..found_word.length-1]

      search_word.scan(/./).each_with_index do |char, index|
        if char == '*'
          found_char = found_word[index..index]
          search_word[index..index] = found_char
        end 
      end
      
      if found_word == search_word && found_word.length == word.length # match?
         return visited_fields
      end
      
      if visited_fields.length < word.length # Stop deepening?
              
        # Deepening
        # Recursively try neighbouring fields
        next_char = word[visited_fields.length..visited_fields.length]
    
        try_field.neighbours.select do |neighbour|
          (next_char == '*' || neighbour.value == next_char) && (!visited_fields.include? neighbour)
        end.each do |neighbour|
          # Broadening
          result = find_word(word, neighbour, visited_fields)
          return result if result
        end      
      end
      return false
    end
  end
end

class Field
  attr_reader :value, :row_idx, :col_idx, :word_search
  
  NEIGHBOUR_COORDINATES = [-1, -1], [-1, 0],[0, -1],
                          [+1, +1], [+1, 0],[0, +1],
                          [+1, -1], [-1, +1]
                          
  def initialize(value, row_idx, col_idx, word_search)
    @value, @row_idx, @col_idx, @word_search = value, row_idx, col_idx, word_search
  end
  
  def neighbours 
    @neighbours ||= NEIGHBOUR_COORDINATES.map do |row_mod,col_mod|
      # Using mod to handle overflowing and negative coordinates
      row = (@row_idx + row_mod) % @word_search.rows.size
      col = (@col_idx + col_mod) % @word_search.row_length
      @word_search.field(row, col)
    end
  end
end

if __FILE__ == $0
  puts "Enter text (empty line when finished):"
  input = []
  loop do 
    input << line = readline
    break if line.gsub(/\s/, '').empty?
  end
  puts "Enter words now (comma separated): "
  input << readline
  puts "Here is the result:"
  puts WordSearch.new(input).solve
end