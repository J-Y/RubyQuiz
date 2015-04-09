@words = File.new('/usr/share/dict/words').read.downcase.scan(/[a-z]+/).uniq
@chars = '0123456789abcdefghijklmnopqrstuvwxyz'

def print_matches(base,minsize=0)

  print "Base: " + base.to_s + "\n"

  alphabet = @chars[0,base]

  print "Alphabet: " + alphabet + "\n\nMatching Words:\n\n"

  @words.each do |w|

    if w.length >= minsize
      hexword = true
      w.each_byte { |c|
      	if !alphabet.include?(c.chr)
      		hexword = false
      		break
      	end
      }
      p w if hexword
    end
  end

end

print_matches 18,4
