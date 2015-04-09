class String
  def lettercount
    split(//).uniq.map{|c| [c, count(c)]}
  end
  def fisher_yates_shuffle
    a = self.dup
    (length-1).downto(0){|i|
      j = rand(i+1)
      a[i], a[j] = a[j], a[i] if i != j
    }
    a
  end
end

class Array
  def random_element
    self[rand(length)]
  end
end

class Dictionary
  def initialize(filename)
    @words = []
    IO.foreach(filename) do |line|
      word = line.chomp
      @words << word.downcase if word.length.between?(3, 6)
    end
  end
  def blend(word)
    @words.select{|x|
      x.count(word.downcase) == x.length &&
      x.lettercount.all?{|c, n|
        n <= word.downcase.lettercount.assoc(c).last }
    }
  end
  def randomword
    @words.select{|x| x.length == 6}.random_element
  end
end

class WordBlender
  def initialize(dictionary)
    @dictionary = dictionary
  end
  def blend_to_s(word)
    word_blend = @dictionary.blend(word)
    puts "WordBlender: '#{word}' has #{word_blend.length} answers."
    puts
    max = -1
    word_blend.sort_by{|x| [x.length, x]}.each do |x|
      if x.length > max
        max = x.length
        puts "Words of length #{max}:"
      end
      puts " #{x}"
    end
  end
  def play
    puts "Welcome to WordBlender! (enter a blank line to quit)"
    puts
    round = 0
    points = 0
    continue = true
    while continue do
      points = points + 10 * round
      round = round + 1
      word = @dictionary.randomword
      word_blend = @dictionary.blend(word)
      word_shuffled = word.fisher_yates_shuffle
      puts "Round: #{round} - Blend: '#{word_shuffled}' - Total Score: #{points}"
      current_word = ""
      current_words = []
      current_continue = true
      while continue && current_continue do
        current_word = STDIN.gets.chomp.downcase
        if current_word == ""
          puts
          puts "Final Word: '#{word}' - Final Score: #{points}"
          continue = false
        elsif current_words.include?(current_word)
          puts "'#{current_word}' already used."
        elsif word_blend.include?(current_word)
          current_words << current_word
          points = points + current_word.length * current_word.length
          current_continue = (current_word.length < word.length)
        elsif current_word.count(word) == current_word.length
          puts "'#{current_word}' not in dictionary."
        else
          puts "'#{current_word}' not found in '#{word_shuffled}'."
        end
      end
    end
  end
end

if ARGV.size == 0
  puts "Usage: wordblender.rb <filename> - play WordBlender with the
specified dictionary"
  puts "Usage: wordblender.rb <filename> <word> - show all blends for
the word using the dictionary"
elsif ARGV.size == 1
  WordBlender.new(Dictionary.new(ARGV[0])).play
elsif ARGV.size >= 2
  WordBlender.new(Dictionary.new(ARGV[0])).blend_to_s(ARGV[1])
end
