require "enumerator"

class Item
 @balance_left = {}
 @balance_right = {}
 @descriptors = []

 attr_reader :parent

 def self.create(description, parent = nil)
   product, remainder = split_product(description)
   return nil if product.nil?
   if(product.length == 1)
     item = create_item(product, parent)
   elsif product.length == 2
     return nil
   else
     item = create_item(product, parent)
     child = create(product[1...-1], item)
     item.wrap(child) unless child.nil?
     if item.empty? && !item.leaf?
       return nil
     end
     if !remainder.empty? && item.root?
       return nil
     end
     unless remainder.empty? || item.root?
       sibling = create(remainder, item)
       item.parent.wrap(sibling)
     end
   end
   return item
 end

 def self.descriptor(d = nil)
   unless d.nil?
     @descriptor = d
     Item.balance(descriptor[0].chr, descriptor[1].chr) if
@descriptor.size == 2
   end
   @descriptor
 end

 def self.regex
   descriptor.length == 2 ?
     "^\\#{descriptor[0].chr}(.*)\\#{descriptor[1].chr}$" : descriptor
 end

 def initialize(parent = nil)
   @items = []
   @parent = parent
 end

 def leaf?
   false
 end

 def empty?
   @items.empty?
 end

 def wrap(i)
   i.parent = self
   @items << i
   self
 end

 def parent=(p)
   @parent = p
 end

 def root?
   @parent.nil?
 end

 def descriptor
   self.class.descriptor
 end

 def description
   unless @items.empty?
     desc = [descriptor[0].chr]
     @items.reverse.each { |i| desc << i.description }
     desc << descriptor[1].chr
     desc.flatten.join
   else
     descriptor
   end
 end

 descriptor ''

 protected

 def self.split_product(description)
   index = 0
   elements = []
   description.split(/\s*/).each_with_index do |c, index|
     if @descriptors.include?(c)
       if @balance_left.include?(c)
         elements.push(c)
       elsif @balance_right.include?(c)
         if elements.last == @balance_right[c]
           elements.pop
         elsif elements.size == 0
           elements.push(c)
         end
       end
       break if elements.size == 0
     end
   end

   if elements.size == 0
     return description[0..index], description[index+1..-1]
   else
     return nil
   end
 end

 def self.balance(first_char, second_char)
   @balance_left[first_char] = second_char
   @balance_right[second_char] = first_char
   @descriptors << first_char unless @descriptors.include?(first_char)
   @descriptors << second_char unless @descriptors.include?(second_char)
 end

 def self.create_item(string, parent = nil)
   ObjectSpace.enum_for(:each_object, class << Item; self; end).to_a.each do |klass|
     next if klass == self
     r = Regexp.new(klass.regex)
     return klass.new(parent) if r.match(string)
   end
   nil
 end
end

class Bracket < Item
 descriptor "B"

 def wrap(i)
   raise "Brackets ain't got no flow"
 end

 def leaf?
   true
 end
end

class SoftWrap < Item
 descriptor "()"
end

class WoodBox < Item
 descriptor "{}"
end

class CardboardBox < Item
 descriptor "[]"
end

pkg_desc = ARGV[0]
package = Item.create(pkg_desc)
exit(1) if package.nil?
puts package.description
