class AVLTree

 include Enumerable

 # Need something smarter than nil for external nodes
 # but we dont need all these separate instances - they are all identical
  class ExternalNode
    def self::include?(_)     false      end
    def self::height;         0          end
    def self::each(*args,&iter)          end
    def self::each_level(sequence,&iter)
      sequence.shift.each_level(sequence,&iter) unless sequence.empty?
    end
    def self::each_node(&iter)  end
    def self::to_a(_); []       end
    def self::pop;  nil         end
    def self::shift; nil        end
    def self::parent=(p); nil   end
    def self::to_s; '';         end
 end

 class Node
   attr_accessor :data, :parent
   attr_reader :left, :right

   def initialize obj, sortblock
     @parent = nil
     @data  = obj
     @left  = ExternalNode
     @right  = ExternalNode
     @height = 1
     @compare = sortblock
   end

   def left=(node)
     @height = nil
     @left = node
     node.parent = self
   end

   def right=(node)
     @height = nil
     @right = node
     node.parent = self
   end

   def each(traversal, &iter)
     case traversal
       when :inorder
         @left.each(traversal,&iter)
          iter[@data]
         @right.each(traversal,&iter)
       when :preorder
          iter[@data]
         @left.each(traversal,&iter)
         @right.each(traversal,&iter)
       when :postorder
         @left.each(traversal,&iter)
         @right.each(traversal,&iter)
          iter[@data]
     end
   end

   def each_level sequence,&iter
     iter[@data]
     sequence.push @left
     sequence.push @right
     sequence.shift.each_level(sequence,&iter) unless sequence.empty?
   end

   def each_node &iter
     @left.each_node(&iter)
     iter[self]
     @right.each_node(&iter)
   end

   def height
     @height || ( [ @left.height, @right.height ].max + 1)
   end

   def << node
     case @compare[node.data,@data]
     when -1
       if Node === @left
         @left << node
       else
         self.left = node
       end
     when 0
       return self            # no dups
     when +1
       if Node === @right
         @right << node
       else
         self.right = node
       end
     end
     rebalance if balance_factor.abs > 1
     @height = nil
   end

   def remove obj
     case @compare[obj,@data]
     when -1
       @left.remove(obj)
     when 0
       path = @left.pop || @right.shift || drop_self
       self.data = path.data
       while Node === (path = path.parent)
         break if path.balance_factor.abs == 1
         path.rebalance
       end
       self
     when +1
       @right.remove(obj)
     end
   end

   def drop_self
     parent.send :replace_child, self, ExternalNode#.new(parent)
     self
   end

   def pop
     @right.pop  || drop_self
   end

   def shift
     @left.shift || drop_self
   end

   def include? obj
     case obj <=> @data
     when -1 : @left.include?(obj)
     when  0 : true
     when +1 : @right.include?(obj)
     end
   end

   def to_a traversal
     left,root,right = @left.to_a(traversal), [@data], @right.to_a(traversal)
     case traversal
       when :inorder
         left+root+right
       when :preorder
        root+left+right
       when :postorder
        left+right+root
       when :by_level
        # pad out the left array so zip gets all the right elements too
        while (left.size < right.size) do left<<nil end
        [root]+left.zip(right).map{|set| set.flatten}
     end
   end

   def [](idx)
       if idx < (leftheight = @left.height)
         @left[idx]
       elsif (idx== leftheight)
         @data
       elsif (idx-=(leftheight+1)) < @right.height
         @right[idx]
       end
   end

   def to_s
     bf = case balance_factor <=> 0
           when -1 : '-' * -balance_factor
           when  0 : '.'
           when  1 : '+' * balance_factor
           end
     "[#{left} "+
       "(#{@data}{#{height}#{bf}}^#{parent.data})"+
       " #{right}]"
   end

   protected

   def balance_factor
     @right.height - @left.height
   end

   def rotate_left
     my_parent, from, to = @parent, self, @right
     temp = @right.left
     @right.left = self
     self.right = temp
     my_parent.send :replace_child, from, to
     to.parent = my_parent
   end

   def rotate_right
     my_parent, from, to = @parent, self, @left
     temp = @left.right
     @left.right = self
     self.left = temp
     my_parent.send :replace_child, from, to
     to.parent = my_parent
   end

   def rebalance
     if (bf = balance_factor) > 1 # right is too high
       if @right.balance_factor < 0
         # double rotate right-left
         # - first the right subtree
         @right.rotate_right
       end
       rotate_left            # single rotate left
     elsif bf < -1            # left must be too high
       if @left.balance_factor > 0
         # double rotate left-right
         # - first force left subtree
         @left.rotate_left
       end
       rotate_right            # single rotate right
     end
   end

   def replace_child(from, to)
     if from.eql? @left
       @left = to
     elsif from.eql? @right
       @right = to
     else
       raise(ArgumentError,
             "#{from} is not a branch of #{self}")
     end
   end

 end

 def initialize(root = ExternalNode, &block)
   @root = root
   if block
     raise(ArgumentError,
       "Block argument for #{self.class.name} must" +
       " take 2 arguments and act as sort function"
       ) unless block.arity == 2
   else
     block = proc{|a,b| a<=>b}
   end
   @compare = block
 end

 def empty?
   @root == ExternalNode
 end

 def include?(obj)
   @root.include?(obj)
 end

 def <<(obj)
   raise(ArgumentError,
         "Objects added to #{self.class.name} must" +
         " respond to <=> (#{obj.inspect})"
         ) unless obj.respond_to?(:<=>)

   if empty?
     @root = Node.new(obj, @compare)
     @root.parent = self
   else
     @root << Node.new(obj, @compare)
   end
   self
 end

  def remove(obj)
   @root.remove(obj).data
  end

 def height
   @root.height
 end

 def [](idx)
   @root[idx]
 end

 def to_a( traversal=:inorder )
   @root.to_a(traversal).flatten.compact
 end

 def each(traversal=:inorder,&iter)
   if traversal==:by_level
     @root.each_level([],&iter)
   else
     @root.each(traversal,&iter)
   end
 end

 def to_s
   empty? ? "[]" : @root.to_s
 end

 # Indicates that parent is root in to_s
 def data; '*'; end

 protected

 def replace_child(from, to)
   if @root.eql? from
     @root = to
   else
     raise(ArgumentError,
           "#{from} is not a branch of #{self}")
   end
 end

end
