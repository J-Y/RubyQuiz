class WordLoop
  def initialize(word)
    raise ArgumentError, "Requires a string of length > 0" if word.to_s.empty?
    @word = word.to_s
    @letters = to_a
    @dups = find_duplicate_letters
  end
  
  def to_a
    @word.split(//)
  end
  
  def find_duplicate_letters
    @seen = Hash.new(0)
    @letters.each { |letter| @seen[letter.downcase] += 1 }
    @seen.inject([]) do |array, (letter, count)|
      array << letter if count > 1
      array
    end
  end
  
  def duplicate_letters?
    @dups.size > 0
  end
  
  def has_loop?
    # To have a loop, the duplicate letters must be separated by an
    # even number of characters greater than 4.
    max_distance = 0
    
    @dups.each do |duplicate_letter|
      loop_start = nil
      loop_end = nil
      
      @letters.each_with_index do |letter, index|
        if letter == duplicate_letter
          if loop_start.nil?
            loop_start = index
          else
            distance = index - loop_start
            if distance % 2 == 0 && distance >= 4
              if distance > max_distance
                @loop_start = loop_start
                @loop_end = index
                max_distance = distance
              end
            end
          end
        end
      end
    end
    
    return max_distance > 0
  end
  
  def generate_array
    tail_count = @word.length - @loop_end - 1
    half_distance = (@loop_end - @loop_start) / 2
    
    width = @loop_start + 2
    height = (@word.length - @loop_end) + half_distance - 1
    output = Array.new(height)
    
    for i in 0...height
      output[i] = Array.new(width, " ")
    end
    
    # I suspect this would be a great place to use a state machine
    # but out of time once again.
    
    x = -1
    y = tail_count
    
    @letters.each_with_index do |letter, index|
      case index
      when 0...width
        x += 1
        output[y][x] = letter
      when (width)...(width + half_distance - 1)
        y += 1
        output[y][x] = letter
      when (width + half_distance - 1)..(@word.length - 1)
        x = width - 2
        y -= 1 unless index == (width + half_distance - 1)
        output[y][x] = letter
      end
    end
    
    output
  end
  
  def to_s
    output_full_array = generate_array
    output_condensed = []
    
    output_full_array.each do |row|
      output_condensed << row.join(" ")
    end
    
    output_condensed.join("\n") + "\n"
  end
end