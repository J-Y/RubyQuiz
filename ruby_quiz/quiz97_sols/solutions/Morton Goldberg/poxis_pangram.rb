#! /usr/bin/env ruby -w
#
#  Created by Morton Goldberg on October 09, 2006.
#
# Ruby Quiz 97 -- POSIX Pangrams
#  quiz_97.4.rb

# Removed c99, fort77, and m4 -- the complication they add is IMHO
# unedifying.
WORDS = %w[
   admin alias ar asa at awk basename batch bc bg cal cat cd cflow
   chgrp chmod chown cksum cmp comm command compress cp crontab csplit
   ctags cut cxref date dd delta df diff dirname du echo ed env ex expand
   expr false fc fg file find fold fuser gencat get getconf getopts
   grep hash head iconv id ipcrm ipcs jobs join kill lex link ln locale
   localedef logger logname lp ls mailx make man mesg mkdir mkfifo more
   mv newgrp nice nl nm nohup od paste patch pathchk pax pr printf prs ps
   pwd qalter qdel qhold qmove qmsg qrerun qrls qselect qsig qstat qsub
   read renice rm rmdel rmdir sact sccs sed sh sleep sort split strings
   strip stty tabs tail talk tee test time touch tput tr true tsort tty
   type ulimit umask unalias uname uncompress unexpand unget uniq unlink
   uucp uudecode uuencode uustat uux val vi wait wc what who write xargs
   yacc zcat
]

# Return true if _wds_ is a pangram.
def pangram?(wds)
   wds.join.split(//).uniq.size == 26
end

# Return array giving pangram statistics:
#     [<words>, <total-chars>, <repeated-chars>]
def stats(pan)
   tmp = pan.join.split(//)
   [pan.size, tmp.size, tmp.size - tmp.uniq.size]
end

# Given a pangram, return a pangram derived from it by removing one word.
def remove_one(pan)
   result = pan.collect do |item|
      diff = pan - [item]
      diff if pangram?(diff)
   end
   result.compact!
   result[rand(result.size)] unless result.empty?
end

# Given a pangram return a minimal pangram derived from it.
def find_minimal(pan)
   nxt = remove_one(pan)
   return pan unless nxt
   find_minimal(nxt)
end

# Find a minimal pangram.
pangram = find_minimal(WORDS)
p pangram # =>
# [
#    "expr", "getconf", "jobs", "mv", "qdel",
#    "type", "unlink", "what", "zcat"
# ]
p stats(pangram) # => [9, 39, 13]
