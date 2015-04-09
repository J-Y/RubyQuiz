#!/usr/bin/env ruby -wKU

class TreeNode

attr_accessor :left, :right, :data #, :parent

def initialize(obj = nil)
  @left=nil
  @right=nil
  @data=obj
end

def attach_left node
  @left = node
end

def attach_right node
  @right = node
end

def height
  [(left.height rescue 0) , (right.height rescue 0)].max + 1
end

def include? obj
  (@data == obj) ||
    (@left.include? obj rescue false) ||
    (@right.include? obj rescue false)
end

def length
  len = 1
  len += @left.length if left
  len += @right.length if right
end

end

class AVLTree

def initialize
 @root = nil
end

def empty?
 ! @root
end

def include?(obj)
 (! empty?) && (@root.include? obj)
end

def <<(obj)
  if empty?
    @root = TreeNode.new obj
  else
    @root = insert(obj, @root)
  end
  self
end

def insert(obj, node)
  if node == nil
    node = TreeNode.new(obj)
  elsif obj < node.data
    node.left = insert(obj, node.left)
  elsif obj > node.data
    node.right = insert(obj, node.right)
 end

  balance = (node.left.height rescue 0)  - (node.right.height rescue 0).abs
  if balance > 1
   if (obj < node.data)
     if (obj < node.left.data)
       node = rotate_with_left_child(node)
     end
   end
  end
  node
end

def rotate_with_left_child(node)
 new_parent = node.left

 node.left = new_parent.right
 new_parent.right = node
 new_parent
end

def height
 empty? ? 0 : @root.height
end

def each
  list = list_nodes(@root, [])
  for data in list
    yield data
  end
end

def list_nodes(node, list)
  list_nodes(node.left, list) if node.left != nil
  list << node.data if node.data != nil
  list_nodes(node.right, list) if node.right != nil
  list
end
end
