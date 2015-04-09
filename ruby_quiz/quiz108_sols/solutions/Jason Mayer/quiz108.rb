require 'set'
DICT = "e:\\ruby\\programs\\rubyquiz\\cropped.txt"
@sixLetterWords = []
@wordlist = []

File.open(DICT) do |x|
  x.each do |@word|
    @word.chomp!.upcase!
    @wordlist.push(@word)
    if @word.length == 6
      @letters = @word.split(//).sort!
      @sixLetterWords.push(@letters) 
    end
  end
end
def loading
  @target=@sixLetterWords[rand(@sixLetterWords.size)]
  puts "Your letters: #{@target.join}"
  @s1 = Set.new(@target)
  @nextround = 0
  @wordsused = []
  @incorrect = 0
end

@score = 0
loading

while @incorrect != 5
  puts "Current score: #{@score}"
  puts "Incorrect: #{@incorrect}"
  if @nextround == 1
    puts "Nextround? (Type 1 at the word: prompt)"
  end

  print "word:"
  compare = gets.chomp
  if @nextround == 1 && compare == "1"
    loading
  end
  
  selection = compare.upcase.split(//).sort
  s2 = Set.new(selection)
  if s2.subset?(@s1)
    if not @wordsused.include?(compare)
      if @wordlist.include?(compare.upcase)
        @incorrect = 0
        @wordsused.push(compare)
        if selection.size == 6
          @score += (10*selection.size.power!(2) + 100)
          @nextround = 1
        else
          @score += (10*selection.size.power!(2))
        end
      else 
        @incorrect += 1
      end
    end
  else
    @incorrect += 1 unless compare ==  "1"
  end
end