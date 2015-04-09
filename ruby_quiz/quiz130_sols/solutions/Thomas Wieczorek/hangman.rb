#Ruby Quiz 130
#solution by Thomas Wieczorek <wieczo.yo@googlemail.com>
#the dictionary comes from http://www.june29.com/IDP/files/German.txt I removed the duplicates and the German words
#11.07.2007
require 'yaml'
$debug = true

class Player

public

  def initialize(word)
    @word = word
    @dictionary = YAML.load_file(DICTIONARYFILE)
    @letters = ('a'..'z').to_a
    @guessed = []
    scan_dictionary(word)
  end
  
  def guess()
    if @dictionary.length == 1 then
      @guessed << @dictionary[0] 
      return @dictionary.pop 
    end
    while (true)
      letter = @probabilities.pop
      next if @guessed.include?(letter[0])
      @guessed << letter[0]
      break
    end
    return letter[0]
  end

  def word=(value)
    
    if not value.include?(".") then
      #lost
      #unknown word
      if not @dictionary.include?(value) then
        @dictionary = load_dictionary()
        @dictionary << value
        File.open(DICTIONARYFILE, "w") { |f| YAML.dump(@dictionary, f) }
      end
    else
      if @word.eql?(value) then
        @word = value
        scan_dictionary(value)
      end
    end
  end
  
private 

  DICTIONARYFILE = "dictionary.yaml"
  
  def scan_dictionary(masked)
    @dictionary = @dictionary or load_dictionary()
    @dictionary = @dictionary.grep(Regexp.new("^#{@word}$"))
    puts "UNKNOWN WORD" if @dictionary.length == 0
    set_probability()
  end
  
  def set_probability
    alphabet = ('a'..'z').to_a
    @probabilities = {}
    alphabet.each { |l| @probabilities[l] = 0 }
    @dictionary.each do |word|
      word.each_byte do |letter|
        #p letter
        l = letter.chr
        @probabilities[l] += 1 if alphabet.include?(l)
      end
    end
    @probabilities = set_standard_probability if @dictionary.length == 0
    @probabilities = @probabilities.sort {|a,b| a[1]<=>b[1]}
  end
  
  #from http://www.fortunecity.com/skyscraper/coding/379/lesson1.htm
  def set_standard_probability
    alphabet = ('a'..'z').to_a
    result = {}
    probabilities = []
    probabilities << 82 << 15 << 28 << 43 << 127 << 22 << 20 << 61 << 70 <<
      2 << 8 << 40 << 24 << 67 << 75 << 19 << 1 << 60 << 63 << 91 << 28 <<
      10 << 23 << 1 << 20 << 1
    alphabet.each_index { |i| result[alphabet[i]] = probabilities[i] }
    return result
  end

  def load_dictionary()
    return YAML.load_file(DICTIONARYFILE)
  end
end #of Player

def random_word
  words = YAML.load_file("dictionary.yaml")
  return words[rand(words.length)]
end

def check_for_letters(word, guess, masked_word)
  if word.include?(guess) then
    word.length.times do |i|
      if word[i].chr == guess then
        masked_word[i] = guess
      end
    end
  end
  
  return masked_word
end

def play_game(word = "", lifes = 6, give_output = false)
  #user given word
  word = random_word if word == ""
  word = word.downcase
  masked_word = word.gsub(/\w/, ".")
  guess = ""

  player = Player.new(masked_word)

  while(lifes > 0)
    #AI guesses a letter or word
    puts "AI is looking for >#{masked_word}<" if give_output
    guess = player.guess()
    new_word = ""
    won = false
    puts "AI guessed '#{guess}'"  if give_output
    if guess.length == 1 then
      masked_word = check_for_letters(word, guess, masked_word)
      
    else 
      if guess.length > 1 then
        break if guess == word
        lifes -= 1
        puts "AI lost a life. #{lifes} lifes left."
        next
      else
        #nil
      end
    end
    
    #wrong guess
    if not masked_word.include?(guess) then
      lifes -= 1
      puts "AI lost a life. #{lifes} lifes left."
    else    
      #found word
      if masked_word == word then
        break
      else
        #found a letter
        player.word = masked_word
        next
      end
    end
  end

  if lifes > 0 then
    won = true
  else
    #give word to player to extend dictionary
    player.word = word
    won = false
  end
  
  return won, word, lifes
end #of play_game

won = false
word = ""
lifes = 6
if ARGV.length > 0
  ARGV.each do |arg|
    option = arg.split("=")
    case option[0]
      when "-w"
        word = option[1]
      when "-l"
        lifes = option[1].to_i
    end
  end
end

won, word, lifes = play_game(word, lifes, true)

if won then
  puts "AI won! It guessed \"#{word}\" with #{lifes} lifes left."
else
  puts "Awww! Lost! AI couldn't guess \"#{word}\"."
end
