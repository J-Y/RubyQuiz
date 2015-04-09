require 'Win32API'  # for checking the keyboard to stop and show the progress

EXAMPLE_SENTENCE = "Darren's ruby panagram program found this sentence which contains exactly
      nine 'a's, two 'b's, five 'c's, four 'd's, thirty-five 'e's, nine 'f's,
      three 'g's,  nine 'h's, sixteen 'i's, one 'j', one 'k', two 'l's, three 'm's,
      twenty-seven 'n's, fourteen 'o's,  three 'p's, one 'q', fifteen 'r's,
      thirty-four 's's, twenty-two 't's, six 'u's, six 'v's, seven 'w's, six 'x's,
      seven 'y's, and one 'z'."


class Pangram
 DEFAULT_SENTENCE = "John's cool pangram program created this sentence which contains exactly"
 ENGLISH_NUMBERS = %w[? one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty]
 ENGLISH_THIRTY_PLUS = %w[thirty forty fifty sixty seventy eighty ninety]
 #this isn't quite right for french: 21 and 31 and 41 are "thirty and one"...
 FRENCH_NUMBERS = %w[? un deux trois quatre cinq six sept huit neuf dix onze douze treize quatorze quinze seize dix-sept dix-huit dix-neuf vingt]
 FRENCH_THIRTY_PLUS = %w[trente quarante cinquante soixante soixante-dix quatre-vingt quatre-vingt-dix]
 MAX_COUNT = 50

 attr_accessor :sentence

 # expect args to be [sentence,number_words,thirty_plus]
 def initialize *args
   @attempts = Hash.new(nil)
   @sentence = args[0] || DEFAULT_SENTENCE
   @words = args[1] || ENGLISH_NUMBERS
   @words = @words.dup
   @thirty_plus = args[1] || ENGLISH_THIRTY_PLUS
   count = 30
   @thirty_plus.each do |word|
     @words[count] = word
     count += 10
   end

   extend_wordlist MAX_COUNT
   #puts "@sentence=#{@sentence}"
   # only add one the first time, all the others already have the extra one

   @result = letter_frequency @sentence
   @result.each { |k,v| @result[k] += 1 }
   #puts full_sentence( @result )
   self
 end

 def distance hash1, hash2
   dist = 0
   hash1.each { |k,v| dist += (v - hash2[k]).abs }
   return dist
 end

 def approximate current, start
   # apply each letter-word to an empty list
   approximation = {}
   "a".upto("z") { |c| approximation[c] = start }
   current.each do |k,v|
     @words[current[k]].split('').each do |c|
       approximation[c] += 1 if approximation[c] and approximation[c] >= 0
     end
   end
   return approximation
 end

 def unique_solution sentence,count
   #puts "#{count}: crypt=#{crypt} for #{sentence}"
   if @attempts[sentence] != nil
     puts "Oops, we've already tried this solution! (#{count} ==> #{@attempts[sentence]})"
     return nil
   else
     @attempts[sentence] = count
     return 1
   end
 end

 def make_randomly_similar! dest, src
   diffs = ""
   dest.each { |k,v| diffs += k if v != src[k] }
   c = diffs[ (rand * diffs.length).to_i ].chr
   dest[c] = src[c]
 end

 def solve
   iteration = 0
   hash = {}
   s = full_sentence( @result )
   hash = letter_frequency( s )
   w = Win32API.new( "MSVCRT", "_kbhit", [], 'i')
   io = IO.new(0)
   while hash != @result ## and unique_solution(s,iteration) != nil
     iteration += 1
     dist = distance( hash, @result )
     puts "#{iteration}: #{dist}"
     c = make_randomly_similar! @result, hash
     #puts "iteration #{iteration}: #{dist},#{c} ==> #{hash.sort.collect{|i| i[1] }.join(',') }"
     s = full_sentence( @result )
     hash = letter_frequency( s )
     if w.Call() > 0
       io.getc
       puts "iteration #{iteration}: #{dist} ==> #{hash.sort.collect {|i| "#{i[0]}>#{i[1]}" }.join(',') }"
       puts s
     end
   end
   puts "\nSOLVED!\n #{s}"
   puts "iteration #{iteration}: #{dist} ==> #{hash.sort.collect {|i| i[1] }.join(',') }"
   show_freq letter_frequency(s)
 end

 def full_sentence hash
   s = @sentence.rstrip + " "
   "a".upto("x") do |letter|
     s += to_letter_count( letter, hash[letter] ) + ", "
   end
   s += to_letter_count( "y", hash["y"] ) + " and "
   s += to_letter_count( "z", hash["z"] ) + "."
   return s
 end

 def to_letter_count letter, count
   ret = "#{@words[count]} '#{letter}'"
   ret += "s" if count > 1
   return ret
 end

 def extend_wordlist count
   0.upto(count) do |n|
     @words[n] = @words[10*(n/10).floor] + '-' + @words[n % 10] unless @words[n]
     #puts "#{n}: #{@words[n]}"
   end
 end

 def show_freq hash
   hash.sort.each { |k, v| puts "#{k}: #{v}" }
 end

 def letter_frequency *sentence
   s = sentence[0] || @sentence
   s = s.downcase.gsub(/^a-z/,'')
   s.gsub!(/ |,|'|-|\./,'')
   freq = Hash.new(0)
   "a".upto("z") { |c| freq[c] = 0 }
   s.split('').each { |c| freq[c] += 1 }
   freq
 end
end
