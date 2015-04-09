#!/usr/bin/env ruby

#This is a variation on my other solution. The same basic mechanisms
#are used for evaluation, but different demarcations are used.

#Code begins at \begin{ruby} or \begin{ruby}[codeword]
#Code ends at \end{ruby} or \end{ruby}[codeword], but only matching
#the original pattern. If a codeword was used to start the block, then 
#the same codeword is required to end the block. If no codeword was used 
#to start the block, then no codeword may be used at the end of the 
#block.

#Of course, if literate blocks don't nest properly in LaTeX, that's 
#beyond the scope of the Ruby Quiz ;-).

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

#process the code to strip the documentation, and the demarcations
inblock=nil
code.map! do |line|

   inblock=nil if inblock and line=~/^\\end\{ruby\}#{Regexp.escape(inblock)}$/

   l=line
   l="\n" if not inblock

   if not inblock and line=~/^\\begin\{ruby\}(\[\w+\])?$/
      if Regexp.last_match[1]
	 inblock=Regexp.last_match[1]
      else
	 inblock=""
      end
   end

   l
end

#the goal here is to have NO local variables or special
#methods introduced into the execution environment
def __ken_binding
   self.class.class_eval {remove_method :__ken_binding}
   binding
end

#evaluate, setting __FILE__ appropriately
eval code.join, __ken_binding , filename
