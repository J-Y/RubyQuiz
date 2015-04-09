class String

  MANGLABLE_WORD = /^[[:alpha:]]{4,}$/

  def to_mangled_s
    split(/\b/).map {|w| w.mangled_word }.join
  end

  def mangled_word
    if match(MANGLABLE_WORD)
      self[0,1] + self[1...-1].scramble! + self[-1, 1]
    else
      self
    end
  end

  def scramble!
    scrambled = ""
    scrambled << slice!(rand(length), 1) until (length == 0)
    replace(scrambled)
  end
  
end

puts ARGF.read.to_mangled_s