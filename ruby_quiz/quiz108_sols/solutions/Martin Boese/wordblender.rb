# wordblender.rb
#
# Usage: wordblender.rb [dictfile]
#

class String
 # Checks if string can be build out of these characters.
 #
 # "hello".build_outof?("llohe") => true
 # "world".build_outof?("dlrowl") => true
 def build_outof?(other)
   return false if self.length > other.length
   o = other.clone
   self.each_byte do |c|
      return false unless o.include?(c.chr)
      o[o.index(c.chr)] = 0
   end
   true 
 end

 # Shuffle a word.
 #
 # "hello".shuffle => "oellh" 
 def shuffle
   return self.scan(/./).sort_by{rand}.to_s
 end
end

class WordBlenderGame

  attr_reader :words

  # limits for words for the game 
  MINCHARACTERS = 3
  MAXCHARACTERS = 6

  # time limit per game
  TIME_PER_GAME = 90

  # how to display the board
  DISPLAY_COLUMNS = 5

  # read the dictionary from a file.
  # we also keep words with length of MAXCHARACTERS to find
  # good initial letters quickly.
  def initialize(dictionary)
    @words, @maxwords = [], []
    File.open(dictionary).each do |line|
      l = line.strip.downcase
      @words << l if (l.length >= MINCHARACTERS && l.length <= MAXCHARACTERS)
      @maxwords << l if l.length == MAXCHARACTERS
    end
  end

  # this generates a bunch of letters to play with and looks up words 
  # that can be build by them from the dictionary ("candidates").
  def prepare_game()
    @letters = @maxwords[rand(@maxwords.size-1)].shuffle
    @candidates = []
    @words.each { |w| @candidates << w if w.build_outof?(@letters) }
    @candidates = @candidates.uniq		# this fixed duplicated entries
    @candidates = @candidates.sort {|x,y| x.length <=> y.length } 
    @found_candidates = @candidates.collect { false }
  end

  #
  # This is to display the candidates to the screen. Draws it into columns 
  # and returns a string.
  #
  def get_board(solution=false, title="Words to find")
     result = "" ; i = 0
     sempty = ' '*(DISPLAY_COLUMNS*(MAXCHARACTERS+2))
     s = String.new(sempty)
     result << title << ":\n"

     @found_candidates.each_index do |idx|
         f = @found_candidates[idx] || solution
         s[i.modulo(DISPLAY_COLUMNS)*(MAXCHARACTERS+2)] = f ? "[#{@candidates[idx]}]" : "["+(' '*@candidates[idx].length)+"]"
         if i.modulo(DISPLAY_COLUMNS) == DISPLAY_COLUMNS-1 then
           result << (s + "\n")
           s = String.new(sempty)
         end
         i+=1
     end
     result << s if s.include?('[')
     result << "\n"
  end


  # This plays one round of the game, returns true if won
  def play
    self.prepare_game    
    message =  "Press RETURN to shuffle the letters, '!' to give up, '?' to cheat."

    # start the time. 
    @time = TIME_PER_GAME
    timer = Thread.new { while true do @time-=1; sleep 1 end }

    # game loop
    while @found_candidates.include?(false) do

       # print board and other stuff
       puts get_board
       puts
       puts  "Time: " + @time.to_s 
       puts  "Msg:  " + message if message != ''
       puts  "Use:  " + @letters
       print "Try:  "

       # get user's guess and handle it
       $stdout.flush
       s = STDIN.gets.downcase.strip

       if @time <= 0 then
         puts "Time's up!"
         break
       end

       if s == "" then
         @letters = @letters.shuffle
         message = "Letters shuffled!"
         next
       end

       break if s == '!'

       if s == '?' then
         puts get_board(true)
         message = "Cheater!"
         next
       end

       if !s.build_outof?(@letters) then
         message = "Invalid word!"
         next
       end

       if @candidates.include?(s) then
         @found_candidates[@candidates.index(s)] = true
         message = "#{s} Found!"
       else
         message =  "#{s} not listed!"
       end
    end

    Thread.kill(timer)

    # print solution
    puts get_board(true, "Solution is")

    # Check if player found a word with all characters
    @found_candidates.each_index do |idx|
      return true if @found_candidates[idx] && @candidates[idx].length == MAXCHARACTERS
    end
    false
  end 
end

print "Loading game...";$stdout.flush
game = WordBlenderGame.new(ARGV[1] || '/usr/share/dict/words')
puts "#{game.words.size} words found."

while game.play do
  puts "You won, press any key to play next round."
  gets
end

puts "Game over!"
