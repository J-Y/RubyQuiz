# RubyQuiz 121 submission
# Bob Showalter

# set to dictionary file to load
DICT = '/usr/share/dict/words'

class Morse

 @@words = nil

 LETTER = Hash[*%w/
    A .-            N -.
    B -...          O ---
    C -.-.          P .--.
    D -..           Q --.-
    E .             R .-.
    F ..-.          S ...
    G --.           T -
    H ....          U ..-
    I ..            V ...-
    J .---          W .--
    K -.-           X -..-
    L .-..          Y -.--
    M --            Z --..
 /]

 # loads dictionary file to limit the words output
 def self.load_dictionary(path)
   @@words = {}
   File.open(path, 'r') do |f|
     while word = f.gets
       @@words[word.chomp.upcase] = true
     end
   end
 end

 # returns list of words starting with prefix that can be made from code
 def self.words(code = @code, prefix = '')
   results = []
   if code == ''
     results << prefix if @@words.nil? || @@words.include?(prefix)
   else
     LETTER.sort.each do |l, p|
       if code[0, p.length] == p
         results += words(code[p.length,code.length], prefix + l)
       end
     end
   end
   results
 end

end

Morse.load_dictionary(DICT) if ARGV.delete('-d')
abort "Usage: #{$0} [-d] code [...]" if ARGV.empty?
ARGV.each do |code|
 puts "#{code}:"
 puts Morse.words(code)
end
