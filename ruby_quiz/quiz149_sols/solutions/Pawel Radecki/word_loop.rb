#!/usr/bin/env ruby

# Solution to Ruby Quiz #149 (see http://www.rubyquiz.com/quiz149.html)
# by Pawel Radecki (pawel.j.radecki@gmail.com).


require 'logger'

$LOG = Logger.new($stderr)

#logging
#$LOG.level = Logger::DEBUG #DEBUG
$LOG.level = Logger::ERROR  #PRODUCTION

NO_LOOP_TEXT = "No loop."

class String
   private
   def compose_word_loop_array (index1, index2)
       a = Array.new(self.length) {|i| Array.new(self.length, " ") }

       i=0
       while (i<index1)
           a[1][i] = self[i].chr
           i+=1
       end

       #repeated letter, first occurrence, loop point
       a[1][index1]=self[index1].chr

       i=index1+1
       boundary = (index2-index1)/2+index1
       while(i<boundary)
           a[1][i] = self[i].chr
           i+=1
       end

       i=index2-1; j=index1
       while(i>boundary-1)
           a[0][j] = self[i].chr
           j+=1; i-=1
       end

       i=index2+1; j=2
       while (i<self.length)
           a[j][index1] = self[i].chr
           i+=1; j+=1
       end

       #cut all empty rows
       a.slice!(j..self.length-1)
       a
   end

   public
   def word_loop
       if (self.length<=4)
           return NO_LOOP_TEXT
       end
       s = self
       index1 = index2 = nil
           #find repeated letter suitable for a loop by
           #taking 1st letter and comparing to 5th, 7th, 9th, 11th, etc.
           #taking 2nd letter and comparing to 6th, 8th, 10th, 12th, etc.
           #taking 3rd letter and comparing to 7th, 9th, 11th etc.
           #etc.
           i = 0
           while i<s.length-1
               j=i+4
               while j<s.length
                   $LOG.debug("i: #{i}")
                   $LOG.debug("j: #{j}")
                   $LOG.debug("s[i]: #{s[i].chr}")
                   $LOG.debug("s[j]: #{s[j].chr}")
                   $LOG.debug("\n")
                   if s[i] == s[j]
                       return compose_word_loop_array(i, j)
                   end
                   j+=2
               end
               i+=1
           end
       return NO_LOOP_TEXT
   end
end

USAGE = <<ENDUSAGE
Usage:
  word_loop <message>
ENDUSAGE

if ARGV.length!=1
   puts USAGE
   exit
end

input_word = ARGV[0]
a = input_word.word_loop
if a.instance_of? Array
   a.each {|x| puts x.join("") }
else
   print a
end

exit
