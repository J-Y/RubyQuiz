#!ruby -s

$morse = Hash[*%w{
  A .- B -...  C -.-.  D -..  E .  F ..-.  G --.  H ....  I ..  J .---
  K -.- L .-..  M -- N -.  O --- P .--.  Q --.- R .-.  S ...  T - U ..-
  V ...- W .-- X -..- Y -.-- Z --..
}].invert

if $d
  words = {}
  File.readlines("/usr/share/dict/words").each { |word|
    words[word.downcase.chomp] = true
  }
end

def allmorse(s, t="", &b)
  if s.empty?
    yield t
  else
    1.upto(s.size) { |n|
      $morse[s[0,n]] && allmorse(s[n..-1], t+$morse[s[0,n]], &b)
    }
  end
end

allmorse (ARGV[0] || ".-...--...-.--").delete("^.-") do |word|
  puts word  if !$d || words.include?(word.downcase)
end
