#!/usr/bin/env ruby

#the literate interpreter cannot be implemented as literate code itself
#for obvious reasons. A literate compiler could.

#I chose to use the line prefix "> " because many email clients have 
#automatic "Add Quote Chars" functions which can add this to the
#beginning of each line, without affecting wrapping. line_prefix=/^> /
#Read the code, and get the file name right
if ARGV[0]
   filename=ARGV.shift
   code=open(filename).readlines
else
   code=STDIN.readlines
   #this is how ruby itself identifies stdin when that's the source
   #of its code
   filename="-"
end
#process the code to strip the documentation, and the line prefix
code.map! do |line|
   if line=~line_prefix
      line.sub(line_prefix,"")
   else
      #we want __LINE__ to return the correct line number in the
      #literate file when we evaluate the file so we don't delete 
      #documentation lines -- we just replace them with blank lines
      "\n" 
   end
end

#the goal here is to have NO local variables or special
#methods introduced into the execution environment
def __ken_binding
   self.class.class_eval {remove_method :__ken_binding}
   binding
end

#evaluate, setting __FILE__ appropriately
eval code.join, __ken_binding , filename
