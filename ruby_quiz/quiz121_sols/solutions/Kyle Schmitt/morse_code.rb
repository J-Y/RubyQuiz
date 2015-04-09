#morse code
#a little inefficient, but easy to follow
letters2morse = {"k"=>"-.-", "v"=>"...-", "l"=>".-..", "w"=>".--", "a"=>".-", "m"=>"--", "x"=>"-..-",
                            "b"=>"-...", "y"=>"-.--", "c"=>"-.-.", "n"=>"-.", "z"=>"--..", "d"=>"-..", "o"=>"---",
                            "e"=>".", "p"=>".--.", "f"=>"..-.", "q"=>"--.-", "g"=>"--.", "r"=>".-.", "h"=>"....",
                            "s"=>"...", "i"=>"..", "t"=>"-", "j"=>".---", "u"=>"..-"}
morse2letters = {}
letters2morse.each_pair do
 |letter,morse|
 morse2letters.store(morse,letter)
end

#for testing
#stringtoconvert = "Sofia".downcase
#encodedstring =stringtoconvert.split('').collect{|i| letters2morse[i]}.join

puts "Enter a word in morse code"
encodedstring = gets().gsub(/[^.-]/,'')#and ignore anything that's not morse

#seed the hash.  the value of each key is the number of times the word was found
#just through it may be interesting later on
huge={encodedstring,0}
huge.default=0

#while anything in the hash has non-morse chars
while(huge.keys.join[/[.-]/]!=nil)
 huge.keys.each do
   |key|
   if key[/[.-]/]!=nil
     morse2letters.each_pair do
     |code,letter|
     huge.store(key.sub(code,letter),huge[key.sub(code,letter)]+1)
     #for each letter of the alphabet, create a new value by replacing
     #the first instance of the letter with it's morse value, and insert it
     #into the hash.
     end
     #encoded all possibilities, now delete it.
     huge.delete(key)
   else
     #continuous output when answers are found
     #puts key
   end
 end
end
puts huge.keys.sort
