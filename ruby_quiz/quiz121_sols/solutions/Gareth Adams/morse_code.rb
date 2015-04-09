class String
  # Calls the given block for every substring with length given in +range+
  #
  # Yields the string's head [0..i] and tail [i..-1] for each i in +range+
  def each_substr(range = [1,self.length])
    raise ArgumentError, "Block required" unless block_given?
    range.first.upto([self.length, range.last].min) do |i|
      yield [ self[0...i], self[i..-1] ]
    end
  end
end


class Morse
  # Windows users like me don't have a dictionary, so use your own if you like
  Dictionary = ['i', 'a', 'an', 'emu', 'pet', 'sofia', 'eugenia']

  Letters = {
    '.-'    => 	:a, '-...'  => 	:b, '-.-.'  => 	:c, '-..'   => 	:d,
    '.'     => 	:e, '..-.'  => 	:f, '--.'   => 	:g, '....'  => 	:h,
    '..'    => 	:i, '.---'  => 	:j, '-.-'   => 	:k, '.-..'  => 	:l, 
    '--'    => 	:m, '-.'    => 	:n, '---'   => 	:o, '.--.'  => 	:p, 
    '--.-'  => 	:q, '.-.'   => 	:r, '...'   => 	:s, '-'     => 	:t, 
    '..-'   => 	:u, '...-'  => 	:v, '.--'   => 	:w, '-..-'  => 	:x, 
    '-.--'  => 	:y, '--..'  => 	:z,
  }

  def initialize code
    raise ArgumentError, "Invalid morse code string" unless
      code.match(/^[.-]+$/)
    self.string = code
  end

  def string=(newstring)
    @string = newstring
    @words  = nil
  end

  # Run the calculation and save each result with a boolean indicating whether
  # it's in the dictionary or not
  def words
    @words ||= self.class.permutate(@string).sort.map do |word|
      [Dictionary.include?(word), word] 
    end
  end

  class << self

    # Generate all valid 'words' from a morse code string
    def permutate morse
      results = []
      # Grab the next 1-4 letters from the string
      morse.each_substr(1..4) do |substr, rest|
        letter = Letters[substr]
        if letter
          # If this substring is a letter, calculate sub-permutations
          # (using the remaining part of the string)
          permutations = permutate(rest)
          if permutations.empty?
            results << "#{letter}"
          else
            # Add each sub-permutation to the current letter, and add that to
            # the list of results
            permutations.each do |permutation| 
              results << "#{letter}#{permutation}"
            end
          end
        end
      end
      results
    end

    # Turns a string back into its morse code form
    def morsify string, separator = '|'
      string.split(//).map do |letter|
        Letters.invert[letter.intern]
      end.join separator
    end
  end

end

if __FILE__ == $0
  while (line = gets.chomp) && !line.empty?
    begin
      out = Morse.new(line).words.map do |in_dict, word|
        "%-#{line.length+2}s %s" %
          [(in_dict ? "[#{word}]" : " #{word}"), "#{Morse.morsify word}"]
      end
    rescue ArgumentError => e
      out = "Invalid morse code string ('#{line}')"
    end
    puts out
  end
end
