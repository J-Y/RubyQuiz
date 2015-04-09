#!/usr/bin/ruby

# removed c99 fort77 m4
words = %w[ admin alias ar asa at awk basename batch bc bg cal cat cd cflow
            chgrp chmod chown cksum cmp comm command compress cp crontab csplit
            ctags cut cxref date dd delta df diff dirname du echo ed env ex
            expand expr false fc fg file find fold fuser gencat get getconf
            getopts grep hash head iconv id ipcrm ipcs jobs join kill lex link
            ln locale localedef logger logname lp ls mailx make man mesg mkdir
            mkfifo more mv newgrp nice nl nm nohup od paste patch pathchk pax pr
            printf prs ps pwd qalter qdel qhold qmove qmsg qrerun qrls qselect
            qsig qstat qsub read renice rm rmdel rmdir sact sccs sed sh sleep
            sort split strings strip stty tabs tail talk tee test time touch
            tput tr true tsort tty type ulimit umask unalias uname uncompress
            unexpand unget uniq unlink uucp uudecode uuencode uustat uux val vi
            wait wc what who write xargs yacc zcat ]
words_line = words.join(" ")

class String
  def letters(&block)
    scan(/[a-z]/, &block)
  end
  
  def pangram?
    letters.uniq.length == 26
  end

  def duplicated_letters
    seen = Hash.new { |found, char| found[char] = 1; 0 }
    letters.inject(0) { |sum, l| sum + seen[l] }
  end
end

OCCURRENCE = Hash.new { |counts, char| counts[char] = 0 }
words_line.letters { |char| OCCURRENCE[char] += 1 }

WORDS_LENGTH = words_line.delete(" ").length

def stats(line)
  puts "String: #{line}"
  puts "Pangram? #{line.pangram?}"
  puts "Words? #{line.split.length}"
  puts "Length? #{line.delete(' ').length}"
  puts "Dupes? #{line.duplicated_letters}"
end

=begin
 Suitability should be determined by
  * least number of letters takes out the length of the computer
  * no used letters
  * no duplicates
=end
def suitability(value, line)
  amount, used = 0, ""
  
  value.letters do |char|
    amount += if used.include?(char) || line.include?(char) 
      -OCCURRENCE[char]
    else
      WORDS_LENGTH / OCCURRENCE[char]
    end
    used << char
  end

  amount
end

line = ""

until line.pangram?
  words.sort! do |x, y|
    suitability(y, line) <=> suitability(x, line)
  end

  line += "#{words.shift} "
end

stats line
