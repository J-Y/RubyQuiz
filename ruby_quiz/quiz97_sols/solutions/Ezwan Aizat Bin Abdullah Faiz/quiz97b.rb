#!/usr/bin/ruby

# removed c99 fort77 m4
words = %w[admin alias ar asa at awk basename batch bc bg
           cal cat cd cflow chgrp chmod chown cksum cmp
           comm command compress cp crontab csplit ctags cut cxref date
           dd delta df diff dirname du echo ed env ex
           expand expr false fc fg file find fold fuser
           gencat get getconf getopts grep hash head iconv id ipcrm
           ipcs jobs join kill lex link ln locale localedef logger
           logname lp ls mailx make man mesg mkdir mkfifo
           more mv newgrp nice nl nm nohup od paste patch
           pathchk pax pr printf prs ps pwd qalter qdel qhold
           qmove qmsg qrerun qrls qselect qsig qstat qsub read renice
           rm rmdel rmdir sact sccs sed sh sleep sort split
           strings strip stty tabs tail talk tee test time touch
           tput tr true tsort tty type ulimit umask unalias uname
           uncompress unexpand unget uniq unlink uucp uudecode uuencode uustat uux
           val vi wait wc what who write xargs yacc zcat]
words_line = words.join(" ");

class String
  def to_a
    chars = []
     self.each_byte do |char|
      chars << char.chr
    end
    chars
  end

  def has_char?(char)
    ! self.to_a.index(char).nil?
  end

  def panagram?
    self.gsub(/\s/, '').to_a.uniq.length == 26
  end

  def duplicated_chars
    chars = []
    dupes = 0
    self.each_byte do |char|
      if chars[char].nil?
        chars[char] = true
      else
        dupes += 1
      end
    end
    dupes
  end
end

OCCURENCE = {}
words_line.gsub(/\s/,'').each_byte do |char|
  char = char.chr
  OCCURENCE[char] = 0 unless OCCURENCE.has_key? char
  OCCURENCE[char] += 1
end

WORDS_LENGTH = words_line.gsub(/\s/,'').length

def stats(line)
  puts "String: " + line
  puts "Panagram? " + line.panagram?.to_s
  puts "Words? " + line.split.length.to_s
  puts "Length? " + line.gsub(/\s/, '').length.to_s
  puts "Dupes? " + line.duplicated_chars.to_s
end

line = ""

=begin
 Suitability should be determined by
  * least number of letters takes out the length of the computer
  * no used letters
  * no duplicates
=end
def suitability(value, line)
  amount = 0

  chars = value.to_a
  used = []
  chars.each do |char|
    mod = OCCURENCE[char]
    unless used.index(char) || line.has_char?(char) 
      amount += WORDS_LENGTH / mod
    else
      amount -= mod
    end
    used << char
  end

  amount
end

until line.panagram?
  words.sort! do |x, y|
    suitability(y, line) <=> suitability(x, line)
  end

  line += words.shift.to_s + " "
end

stats line
