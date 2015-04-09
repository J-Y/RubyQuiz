#!/usr/bin/env ruby -wKU

class AVLTree
attr_accessor :left, :right
def initialize
  @content = nil
  @left = @right = nil
end

def empty?
  !@content
end

def include?(obj)
  (@content == obj) ||
    (@left and @left.include?(obj)) ||
    (@right and @right.include?(obj))  ||
    false
end

def <<(obj)
  if empty?
    @content = obj
  else
   @left ||= AVLTree.new
   @right ||= AVLTree.new
    if obj < @content
      @left << obj
     else
      @right <<obj
    end
    balance = @right.height - @left.height
    if (balance > 1)
      pivot = @right
      @right  = pivot.left
      pivot.left = self
     end
  end
  self
end

def height
  lh = (@left && @left.height)||0
  rh = (@right&&@right.height)||0
  1 + [lh,rh].max
end


def remove(obj)
  if @content == obj
    @content = nil
  else
    @left.remove(obj)
    @right.remove(obj)
   end
end

def value
  @content
end

end
