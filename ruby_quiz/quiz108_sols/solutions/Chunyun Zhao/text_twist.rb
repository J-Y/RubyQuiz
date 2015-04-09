#== Synopsis
#This is the solution to Ruby Quiz #108 described on http://www.rubyquiz.com/quiz108.html.
#
#== Usage
#   text_twist.rb dictionary_file
#
#== Author
#   Chunyun Zhao(chunyun.zhao@gmail.com)
#
class Dictionary
 MIN_LEN, MAX_LEN = 3, 6
 attr_reader :max_letters
 def initialize(dict_file, min=MIN_LEN, max=MAX_LEN)
   @min_len = min
   @max_len = max
   @words = Hash.new {|hash,key|hash[key]=[]}
   File.foreach(dict_file) {|word|add_word(word.strip)}
   @max_letters = @words.keys.select {|key| key.size==@max_len}
 end
 def word_list(letters)
   words=[]
   permutate(letters).select {|letters|
     letters.size.between? @min_len, @max_len
   }.uniq.each {|key|
     words += @words[key]
   }
   words.sort_by {|word| word.size}
 end
 private
 def add_word(word)
   if (@min_len..@max_len)===word.size && word=~/^[a-z]+$/i
     word.downcase!
     @words[word.split(//).sort] << word
   end
 end
 def permutate(letters)
   _letters = letters.dup
   result = []
   while letter = _letters.shift
     permutate(_letters).each do |perm|
       result << [letter] + perm
     end
     result << [letter]
   end
   result
 end
end

Task = Struct.new(:letters, :words)

class GameUi
 def initialize(dict)
   @dictionary = dict
   @history_tasks = []
   @rounds = 1
   @score = 0
 end

 def run
   while run_task
     answer = ask("\nProceed to next round?")
     break if answer !~ /^y/i
     @rounds += 1
   end
   puts "\nYou've cleared #{cleared=@cleared?@rounds:@rounds-1} round#{'s' if cleared > 1}, and your total score is #{@score}."
 end

 private
 def next_task
   letters = @dictionary.max_letters[rand(@dictionary.max_letters.size)]
   retry if @history_tasks.include?(letters)
   task = Task.new(letters, @dictionary.word_list(letters))
   @history_tasks << task
   task
 end

 def run_task
   @task = next_task
   @found = []
   @cleared = false
   puts "\nRound #{@rounds}. Letters: #{@task.letters*', '}. Hint: number of matching words: #{@task.words.size}"
   while !(word=ask("Enter your word:")).empty?
     if @found.include? word
       puts "Word already found!"
     elsif @task.words.include? word
       @found << word
       @score += word.size
       puts "Good job! You scored #{word.size} points!"
       if word.size == @task.letters.size
         @cleared = true
         puts "\nBingo! Round #@rounds cleared. You found #{@found.size} word#{'s' if @found.size > 1}. "
         break
       end
     else
       puts "Wrong word!"
     end
   end
   puts "Missed words: #{(@task.words-@found)*', '}."
   @cleared
 end

 def ask question
   print question, " (Hit enter to exit)=> "
   gets.strip.downcase
 end
end
if __FILE__ == $0
 if ARGV.size != 1
   puts "Usage: #{File.basename(__FILE__)} dictionary_file"
   exit
 end
 GameUi.new(Dictionary.new(ARGV.shift)).run
end
