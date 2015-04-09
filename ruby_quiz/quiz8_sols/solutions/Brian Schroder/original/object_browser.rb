require 'browser-ui.rb'

# Class Tree
class ClassTreeNode
  attr_accessor :klass, :subclasses, :objects
  
  def initialize(klass)
    @klass = klass
    @subclasses = {}
    @objects = []
  end

  def add_class(klass)
    @subclasses[klass] ||= ClassTreeNode.new(klass)
  end

  def add_object(object)
    @objects << object
    self
  end
end

# Creates or updates a klass_tree.
# When updating no classes or objects are removed
def object_browser(classtree = ClassTreeNode.new(Kernel))
  ObjectSpace.each_object do | x |
    classnode = classtree
    x.class.ancestors.reverse[1..-1].inject(classtree){ | classnode, klass | classnode.add_class(klass) }.add_object(x)
  end  
  classtree
end

# Call somewhere in a program to browse the objects.
def browse_objects
  Gtk.init
  win = ObjectTreeViewWindow.new(ARGV[0]).set_default_size(400, 400).show_all
  Gtk.main
end
