#!/usr/bin/env ruby -wKU

class AVLTree

 def empty?
   !@contents
 end

 def include?(obj)
   return @contents == obj
 end

 def <<(obj)
   @contents = obj
 end

end
