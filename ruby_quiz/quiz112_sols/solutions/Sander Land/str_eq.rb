require 'matrix'

class String
 def to_freq
   ('a'..'z').map{|c| Rational(count(c)) }  # use Rational for stability in calculating rank
 end
end

def has_string_eqn(words)
 table = words.uniq.map{|w| w.downcase.gsub(/[^a-z]/,'').to_freq }.transpose
 nullity = words.length - Matrix[*table].rank
 return nullity > 0
end
