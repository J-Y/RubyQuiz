#!/usr/bin/ruby

words = %w{admin alias ar asa at awk basename batch bc bg
           c99 cal cat cd cflow chgrp chmod chown cksum cmp
           comm command compress cp crontab csplit ctags cut cxref date
           dd delta df diff dirname du echo ed env ex
           expand expr false fc fg file find fold fort77 fuser
           gencat get getconf getopts grep hash head iconv id ipcrm
           ipcs jobs join kill lex link ln locale localedef logger
           logname lp ls m4 mailx make man mesg mkdir mkfifo
           more mv newgrp nice nl nm nohup od paste patch
           pathchk pax pr printf prs ps pwd qalter qdel qhold
           qmove qmsg qrerun qrls qselect qsig qstat qsub read renice
           rm rmdel rmdir sact sccs sed sh sleep sort split
           strings strip stty tabs tail talk tee test time touch
           tput tr true tsort tty type ulimit umask unalias uname
           uncompress unexpand unget uniq unlink uucp uudecode uuencode uustat uux
           val vi wait wc what who write xargs yacc zcat }
line = ""

flags = {}
letters = {}
('a'..'z').to_a.each do |char| 
  char = char.to_sym
  flags[char]   = false
  letters[char] = []
end

words.each do |word|
  word.each_byte do |char|
    # removes words with numbers in them
    next if (char < 'a'[0] || char > 'z'[0])
    char = char.chr.to_sym
    tmp = letters[char]
    tmp << word
  end
end

class String
  def to_a
    chars = []
     self.each_byte do |char|
      chars << char.chr
    end
    chars
  end
end

def suitability(value, flags)
  value = value.to_a
  amount = 0
  chars = value.uniq
  chars.each do |char|
    char = char.to_sym
    amount += 1 if flags[char] == false
  end

  amount
end

while flags.has_value? false
  # Remove empty elements from the list
  letters.delete_if { |key, value| value.empty? }

  # Determine the most suitable word for each element
  letters.each_key do |key|
    # Shifts the most suitable word to the start of the array
    letters[key].sort! do |x, y|
      suitability(y, flags) <=> suitability(x, flags) 
    end
  end

  largest_amount = letters.keys[0]
  letters.each do |key, value|
    # Compare the most suitable word
    largest_amount = key if suitability(letters[key][0], flags) > suitability(letters[largest_amount][0], flags)
  end

  # Remove the most suitable word
  word = letters[largest_amount].shift

  letters.each do |key, value|
    value.delete(word)
  end

  line   += word + " "

  word.to_a.each do |value|
    if flags[value.to_sym] == false
      flags[value.to_sym] = word
    end
  end
end

puts line
puts "length: " + line.gsub(/\s/,'').length.to_s

('a'..'z').to_a.each do |key|
  puts key + " was taken out by " + flags[key.to_sym].to_s
end
