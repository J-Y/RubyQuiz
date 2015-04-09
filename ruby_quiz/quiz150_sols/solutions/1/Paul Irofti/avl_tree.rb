#!/usr/bin/env ruby -wKU                                                

class AVLTree                                                           
 attr_accessor :head
 def initialize
   @head = nil
 end
 def empty?
   @head.nil?
 end
 def << (thing)
   @head = thing if empty?
 end
 def include?(value)
   @head == value
 end
end     
