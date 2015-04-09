#!/usr/bin/env ruby -wKU

class AVLTree

 def initialize
   @contents = []
 end

 def empty?
   @contents.empty?
 end

 def include?(obj)
   @contents.include?(obj)
 end

 def <<(obj)
   @contents << obj
 end

 def height
 end

end
