#!/usr/bin/env ruby
# Object Browser Tree View
#
# Based on an example by Masao Mutoh.
# (c) 2004 Brian Schröder
#
# You can redistribute it and/or modify it under the terms of
# the Ruby licence.
#
Thread.abort_on_exception = true

require 'gtk2'

class PixStringColumn < Gtk::TreeViewColumn
  def initialize(title = '')
    
    super(title)
    resizable = true
    pix = Gtk::CellRendererPixbuf.new
    self.pack_start(pix, false)
    self.set_cell_data_func(pix) do |column, cell, model, iter|
      cell.pixbuf = iter.get_value(0) 
    end

    text = Gtk::CellRendererText.new
    self.pack_start(text, false)
    self.set_cell_data_func(text) do |column, cell, model, iter|
      cell.text = iter.get_value(1)
    end
  end
end

class StringColumn < Gtk::TreeViewColumn
  def initialize(title = '')
    super(title)
    resizable = true
    alignment = 1.0
    text = Gtk::CellRendererText.new
    self.pack_start(text, false)
    self.set_cell_data_func(text) do |column, cell, model, iter|
      cell.text = iter.get_value(3)
    end
  end
end

class PixStringTree < Gtk::TreeView
  attr_accessor :formats
  
  def initialize(data, model = Gtk::TreeStore.new(Gdk::Pixbuf, String, Object, String))
    @formats = {:class => [Gtk::Stock::YES, "#000088"],
      :object => [Gtk::Stock::NO, "#008800"],
      :method => [Gtk::Stock::APPLY, "black"],
      :variable => [Gtk::Stock::BOLD, "#AA9900"],
      :constant => [Gtk::Stock::BOLD, "#AA9900"],
      :h1 => [Gtk::Stock::YES, "#000088"],
      :h2 => [Gtk::Stock::NO, "#008800"],
      :h3 => [Gtk::Stock::APPLY, "black"]}

    super(model)

    @column = PixStringColumn.new('')
    @column2 = StringColumn.new('Id')
    append_column(@column)
    append_column(@column2)
    set_rules_hint(true)
    fill_tree(data)
    signal_connect(:size_allocate) do |widget, allocation|
      x,y,width,h = *allocation.to_a
      @column.max_width = 2 * width / 3
      @column2.max_width = width / 3
    end
  end

  def clear
    self.model.clear
  end

  def insert_node(parent, type, text, id = '', data = nil)
    iter = self.model.append(parent)
    iter.set_value(0, render_icon(@formats[type][0], Gtk::IconSize::MENU, text))
    iter.set_value(1, text)
    iter.set_value(2, data)
    iter.set_value(3, id)
  end

  def fill_tree(*args)
    clear
    begin
      self.model.freeze_notify
      fill_model(*args)
    ensure
      self.model.thaw_notify
    end
    self
  end
end

class String
  def shorten(length)
    return self if self.length <= length
    return self[0..length-3]+'...' 
  end
end


def to_simple_str(object)
  object.respond_to?(:to_s) ? object.to_s : "#<#{object.id.to_s(16)}>"
end

def string_display(object, length = 1.0/0.0)
  case object
  when Hash:  if object.length > length
                '{' + object.to_a[0..length].map{|k, v| "#{to_simple_str(k)} => #{to_simple_str(v)}"}.join(',') + ', ...}'
              else
                '{' + object.to_a.map{|k, v| "#{to_simple_str(k)} => #{to_simple_str(v)}"}.join(',') + '}'
              end
  when Array: if object.length > length
                '[' + object[0..length].map{|v| to_simple_str(v)}.join(',') + ', ...]'
              else
                '[' + object.map{|v| to_simple_str(v)}.join(',') + ']'
              end
  when Symbol: ':' + object.to_s
  when Numeric: object.to_s
  when Method: object.inspect
  else (object.respond_to?:to_s) ? object.to_s : object.inspect
  end
end

# List all classes and all objects with their class.
class ClassTreeView < PixStringTree
  attr_reader :object_selected
  
  def initialize(*args)
    @object_selected = lambda{}
    super(*args)
    signal_connect('row-activated') do | treeview, path, column |
      iter = self.model.get_iter(path)
      object = iter[2]
      self.object_selected.call(object, iter)
    end
    signal_connect('row-expanded') do | tree_view, iter, path | beautify(iter) end
  end

  def beautify(iter)
    Thread.new(self) do | tree_view |
      iter = iter.first_child
      begin               
        object = iter[2]
        if object.is_a?Class
        else
          iter[1] = string_display(object, 8).shorten(32).inspect[1..-2]
        end
      end while iter.next!
    end
  end

  def on_object_selected(&callback)
    @object_selected = callback
  end
  
  def fill_model(classnode, parent = nil)
    node = insert_node(parent, :class, classnode.klass.to_s, "#<#{classnode.klass.id.to_s(16)}>", classnode.klass)
    classnode.objects.each do | object |
      insert_node(node, :object, "#<#{object.id.to_s(16)}>",  "#<#{object.id.to_s(16)}>", object)
    end
    classnode.subclasses.to_a.sort_by{|k,s| k.to_s}.each do | klass, subclass | fill_model(subclass, node) end
  end
end

module ObjectInspectorsMixin
  @@tests = []

  def ObjectInspectorsMixin.register_inspector(method_name, &test)
    @@tests.unshift([test, method_name])
  end

  register_inspector(:inspect_object) do true end
  
  def inspect(object, parent)
    @@tests.each do | test, method_name |
      if test.call(object)
        send(method_name, object, parent)
        break
      end
    end
  end

  def add_methods(object, parent)
    return unless show_methods
    
    [['Public Methods', :public_methods],
      ['Protected Methods', :protected_methods],
      ['Private Methods', :private_methods],
      
      ['Public Instance Methods', :public_instance_methods],
      ['Protected Instance Methods', :protected_instance_methods],
      ['Private Instance Methods', :private_instance_methods]].each do | title, list_method |
      next unless object.respond_to?list_method
      if show_empty || !object.send(list_method, true).empty?
        section = insert_node(parent, :h1, title)
        methods = object.send(list_method, false).sort
        if show_empty || !methods.empty?
          methods_node = insert_node(section, :h2, 'Own Methods')
          methods.each do | method |
            arity = object.instance_eval("self.method('#{method}').arity") rescue 0
            insert_node(methods_node, :method, "#{method}(#{args_from_arity(arity)})")
          end
        end

        methods = (object.send(list_method, true) - object.send(list_method, false)).sort
        if show_empty || !methods.empty?
          methods_node = insert_node(section, :h2, 'Inherited Methods')
          methods.each do | method |
            arity = object.instance_eval("self.method('#{method}').arity") rescue 0
            insert_node(methods_node, :method, "#{method}(#{args_from_arity(arity)})")
          end
        end
      end
    end
  end

  def add_instance_variables(object, parent)
    return unless show_state
    return unless object.respond_to?:instance_variables
    
    if show_empty || !object.instance_variables.empty?
      section = insert_node(parent, :h1, 'State')
      object.instance_variables.each do | varname |
        value = object.instance_variable_get(varname)
        node = insert_node(section, :variable, "#{varname} = #{string_display(value)}", "#{description(value)} #<#{value.id.to_s(16)}>", value)
        model.append(node)
      end
    end    
  end

  def add_modules(object, parent)
    return unless show_methods
    return unless object.respond_to?:included_modules
    
    if show_empty || !object.included_modules.empty?
      section = insert_node(parent, :h1, 'Included Modules')
      object.included_modules.each do | mod |
        node = insert_node(section, :class, "#{mod}", "<#{mod.id.to_s(16)}>", mod)
        model.append(node)
      end
    end
  end

  def add_class_variables(object, parent)
    return unless show_state
    return unless object.respond_to?:class_variables
    
    if show_empty || !object.class_variables.empty?
      section = insert_node(parent, :h1, 'Class Variables')
      object.class_variables.each do | varname |
        value = object.class_eval(varname)
        node = insert_node(section, :variable, "#{varname} = #{string_display(value)}", "#{description(value)} #<#{value.id.to_s(16)}>", value)
        model.append(node)
      end
    end    
  end

  def add_constants(object, parent)
    return unless show_state
    return unless object.respond_to?:constants
    
    if show_empty || !object.constants.empty?
      section = insert_node(parent, :h1, 'Constants')
      object.constants.each do | varname |        
        value = object.const_get(varname)
        node = insert_node(section, :constant, "#{varname} = #{string_display(value)}", "#{description(value)} #<#{value.id.to_s(16)}>", value)
        model.append(node)
      end
    end    
  end

  private
  def args_from_arity(arity)
    arg = 'a'
    args = []
    if arity < 0
      (-arity - 1).times do args << arg; arg = arg.succ end
      args << '*'+arg
    else
      arity.times do args << arg; arg = arg.succ end
    end
    args.join(', ')
  end

  protected
  def description(object)
    if object.is_a?Class
      "Class #{object.to_s}"
    elsif object.is_a?Module
      "Module #{object.to_s}"
    elsif object.is_a?(Proc) || object.is_a?(Method)  || object.is_a?(UnboundMethod)
      "#{object.class} #{object.to_s}(#{args_from_arity(object.arity)})"
    elsif object.is_a?Object      
      "#{object.class.to_s}"
    end
  end

  def inspect_object(object, parent)
    parent = insert_node(parent, :object, "#{string_display(object)}", "#{description(object)} #<#{object.id.to_s(16)}>") unless parent
    add_constants(object, parent)
    add_instance_variables(object, parent)
    add_class_variables(object, parent)
    add_methods(object, parent)
    add_modules(object, parent)
  end
end

module ObjectInspectorsMixin
  register_inspector(:inspect_array) do | o | o.is_a?Array end

  def add_enumeration(object, parent)
    return unless show_state
    if object.respond_to?:each_with_index 
      section = insert_node(parent, :h1, 'Content')
      object.each_with_index do | value, index |
        node = insert_node(section, :constant, "[#{index}] = #{string_display(value)}", "#{description(value)} #<#{value.id.to_s(16)}>", value)
        model.append(node)
      end
    elsif object.respond_to?:each 
      section = insert_node(parent, :h1, 'Content')
      object.each do | value |
        node = insert_node(section, :constant, "#{string_display(value)}", "#{description(value)} #<#{value.id.to_s(16)}>", value)
        model.append(node)
      end
    end
  end
  
  def inspect_array(object, parent)
    parent = insert_node(parent, :object, "#{string_display(object)}", "#{description(object)} #<#{object.id.to_s(16)}>") unless parent    
    add_constants(object, parent)
    add_instance_variables(object, parent)
    add_enumeration(object, parent)
    add_class_variables(object, parent)
    add_methods(object, parent)
    add_modules(object, parent)
  end
end

module ObjectInspectorsMixin
  register_inspector(:inspect_hash) do | o | o.is_a?Hash end

  def add_hash_values(object, parent)
    return unless show_state
    return unless object.respond_to?:each
    section = insert_node(parent, :h1, 'Content')
    object.each do | key, value |
      node = insert_node(section, :constant, "#{key} => #{string_display(value)}", "#{description(value)} #<#{value.id.to_s(16)}>", value)
      model.append(node)
    end
  end
  

  def inspect_hash(object, parent)
    parent = insert_node(parent, :object, "#{string_display(object)}", "#{description(object)} #<#{object.id.to_s(16)}>") unless parent    
    add_constants(object, parent)
    add_instance_variables(object, parent)
    add_hash_values(object, parent)
    add_class_variables(object, parent)
    add_methods(object, parent)
    add_modules(object, parent)
  end
end

class ObjectTreeView < PixStringTree
  attr_reader :show_empty, :show_methods, :show_state
  
  include ObjectInspectorsMixin
  
  def initialize(*args)
    super(*args)
    @show_empty = false
    @show_methods = false
    @show_state = true
    signal_connect('row-expanded') do | tree_view, iter, path |
      object = iter[2]
      child = iter.first_child
      if (! child[0]) and (object)
        new_child = fill_model(object, iter)
        self.model.remove(child)    # REMOVE DUMMY CHILD 
      end
    end
  end

  def show_empty=(value)
    @show_empty = value
    rebuild_tree
  end
  
  def show_methods=(value)
    @show_methods = value
    rebuild_tree
  end
  
  def show_state=(value)
    @show_state = value
    rebuild_tree
  end
  
  def intersect(a1, a2)
    a1 - (a1 - a2)    
  end
  
  def fill_model(object, parent = nil)
    @object = object unless parent
    inspect(object, parent)
  end

  protected
  def rebuild_tree
    fill_tree(@object)
  end
end

class ObjectTreeViewWindow < Gtk::Dialog
  def initialize(object_tree)
    super("Object Tree Viewer for Ruby", nil, 
          Gtk::Dialog::MODAL|Gtk::Dialog::NO_SEPARATOR,
          ['Show/Hide Empty Entrys', -1], ['Show/Hide State', -2], ['Show/Hide Methods', -3], [Gtk::Stock::QUIT, 2])

    hbox = Gtk::HBox.new()
    vbox.add(hbox)
    object_tree = object_browser
    tv = ClassTreeView.new(object_tree)
    hbox.add(Gtk::ScrolledWindow.new.add(tv))
    ov = ObjectTreeView.new(Kernel)
    hbox.add(Gtk::ScrolledWindow.new.add(ov))
    
    tv.on_object_selected do | object, iter | ov.fill_tree(object) end
    
    signal_connect(:response) do |widget, response|
      case response
      when -1: ov.show_empty = !ov.show_empty
      when -2: ov.show_state = !ov.show_state
      when -3: ov.show_methods = !ov.show_methods
      when 2: destroy; Gtk.main_quit
      end
    end
    self.show_all    
  end
end
