require 'rubygems'
gem 'raspell'
require 'raspell'

class MCheck
   def initialize(message, mmap)
       @aspell = Aspell.new
       @mmap = mmap
       matches(message)
   end
   def matches(str,s="")                #recursively check string for
       @mmap.each do |n,o|              #every possible letter
           if str =~ /^#{n}(.*)$/
               num = "#{s}#{@mmap[n]}"
               if $1 == ""
                   x = @aspell.check(num) ? "*" : " "
                   puts " #{x} #{num}"
               else
                   matches($1, num)
               end
           end
       end
   end
end
MCheck.new(gets.gsub(/[^\.\-]+/, ''), Hash[*"A .- N -.
B -... O ---
C -.-. P .--.
D -.. Q --.-
E . R .-.
F ..-. S ...
G --. T -
H .... U ..-
I .. V ...-
J .--- W .--
K -.- X -..-
L .-.. Y -.--
M -- Z --..".gsub(/(\.|\-)/, '\\\\\1').split(/\n| /)].invert) #Escape . and - for regexx, and create hash
