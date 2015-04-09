require 'object_browser_ui'
require 'gtk2'

Thread.abort_on_exception = true

module ObjectBrowser
  module UI
    module Gtk
      include ::Gtk
      
      module Value
        ICON = 0
        TEXT = 1
        ADDITIONAL_TEXT = 2
        OBJECT = 3
      end

      # A column that contains a pixbuffer followed by a text renderer. 
      class PixTextColumn < TreeViewColumn
        # Initialize column with a title and the index of the pixbuffer in the
        # iterator and the text index in the iterator.
        def initialize(title = '', pix_index = 0, text_index = 1)
          super(title)

          pix = Gtk::CellRendererPixbuf.new
          self.pack_start(pix, false)
          self.set_cell_data_func(pix)  do |column, cell, model, iter| cell.pixbuf = iter.get_value(pix_index) end

          text = Gtk::CellRendererText.new
          self.pack_start(text, false)
          self.set_cell_data_func(text) do |column, cell, model, iter| cell.text = iter.get_value(text_index)  end
        end
      end

      # A column that contains only a text
      class TextColumn < TreeViewColumn
        # initialize with column title and the index of the text in the iterator.
        def initialize(title = '', text_index = 0)
          super(title)

          text = Gtk::CellRendererText.new
          self.pack_start(text, false)
          self.set_cell_data_func(text) do |column, cell, model, iter| cell.text = iter.get_value(text_index)  end
        end
      end

      class BrowserTree < TreeView
        # Create a new tree. The default model contains a pixbuf, string, string and object.
        def initialize(model = Gtk::TreeStore.new(Gdk::Pixbuf, String, String, Object))
          super(model)

          set_rules_hint(true)

          @formats = {:class => [Gtk::Stock::YES, 'blue'],
            :object => [Gtk::Stock::NO, 'black'],
            :method => [Gtk::Stock::APPLY, 'black'],
            :variable => [Gtk::Stock::BOLD, 'red'],
            :constant => [Gtk::Stock::BOLD, 'blue'],
            :h1 => [Gtk::Stock::YES, 'black'],
            :h2 => [Gtk::Stock::NO, 'black'],
            :h3 => [Gtk::Stock::APPLY, "black"]}
          @formats.default = [Gtk::Stock::NO, 'black']
          
          column1 = PixTextColumn.new('How to call this?', Value::ICON, Value::TEXT)
          column2 = TextColumn.new('Additional', Value::ADDITIONAL_TEXT)
          append_column(column1)
          append_column(column2)
          column1.resizable = column2.resizable = true
          column2.alignment = 1.0

          # TODO: Make this resizable, but let it fill only the available width.
          signal_connect(:size_allocate) do |widget, allocation|
            x,y,width,h = *allocation.to_a
            column1.max_width = 2 * width / 3
            column2.max_width = width / 3
          end
        end

        # Set the format for some type of line
        #
        # E.g.
        #   set_format(:class, Stock::YES, 'blue')
        def set_format(type, image, color)
          @formats[type] = [image, color]
        end

        # Empty the tree
        def clear
          self.model.clear
        end

        # Add a node to the model. If parent is nil the node will be added as a root node.
        # Returns an iterator that point to the inserted node.
        def insert_node(parent, type, text, additional = '', object = nil)
          text = text.to_s
          additional = additional.to_s if additional
          iter = self.model.append(parent)
          iter.set_value(Value::ICON, render_icon(@formats[type][0], Gtk::IconSize::MENU, text))
          iter.set_value(Value::TEXT, text)
          iter.set_value(Value::ADDITIONAL_TEXT, additional) if additional
          iter.set_value(Value::OBJECT, object) if object
          iter
        end

        # Clear the tree, freeze it and call a block in which the tree can be filled.
        def change_tree(*args)
          begin
            self.model.freeze_notify
            yield(self, *args)
          ensure
            self.model.thaw_notify
          end
          self
        end
      end

      # Lists all classes and all objects with their class.
      class ClassBrowser < BrowserTree
        def initialize(classtree, object, *args)
          @object_selected = lambda{}
          super(*args)
          signal_connect('row-activated') do | treeview, path, column |
            iter = self.model.get_iter(path)
            @object_selected.call(iter[3], iter)
          end
          signal_connect('row-expanded') do | treeview, iter, path | beautify(iter) end
          update_tree(classtree, object)
        end

        # Set on_object_selected callback
        def on_object_selected(&callback)
          @object_selected = callback
        end

        # Load a new classtree into the class browser
        def update_tree(classtree, object = nil)
          self.change_tree do
            self.clear
            self.fill_model(classtree)
            #TODO: Navigate to object object
          end
        end
        
        protected
        # Fill the class tree from a classtree structure
        def fill_model(classnode = ::ObjectBrowser::create_class_tree(), parent = nil)
          node = insert_node(parent, :class, classnode.klass.to_s, "#<#{classnode.klass.id.to_s(16)}>", classnode.klass)
          classnode.objects.each do | object |
            insert_node(node, :object, "#<#{object.id.to_s(16)}>",  "#<#{object.id.to_s(16)}>", object)
          end
          classnode.subclasses.to_a.sort_by{|k,s| k.to_s}.each do | klass, subclass | fill_model(subclass, node) end
        end

        protected
        # Get detailed information about each child of iter and update its presentation. This happens in a thread, such that
        # browsing of the tree can continue. beautify is called, after part of a tree has been expanded.
        #
        # Todo: Check if this is thread safe.
        def beautify(iterator)
          Thread.new(iterator) do | iter |
            iter = iter.first_child
            begin
              object = iter[Value::OBJECT]
              iter[Value::TEXT] = DEFAULT_DESCRIBER.display_string(object, 64).inspect[1..-2]
            end while iter.next!
          end
        end
      end

      class ObjectTreeView < BrowserTree
        # TODO: Factor this out such that I only have to write:
        # attr_updater [:show_empty, :rebuild_tree], [:show_methods, :rebuild_tree], [:show_state, :rebuild_tree]
        attr_reader :show_empty, :show_methods, :show_state
        def show_empty=(value)   @show_empty = value;   rebuild_tree; end
        def show_methods=(value) @show_methods = value; rebuild_tree; end 
        def show_state=(value)   @show_state = value;   rebuild_tree; end
        
        def initialize(object, *args)
          super(*args)
          @show_empty = false
          @show_methods = true
          @show_state = true
          
          signal_connect('row-expanded') do | tree_view, iter, path |
            object = iter[Value::OBJECT]
            child = iter.first_child
            if !child[0] and object # Expand object for the first time.
              update_tree(object, iter)
              self.model.remove(child) # Remove dummy child
            end
          end
        end

        # Update the tree information by expanding a model. A parent of nil inserts the object into the root.
        def update_tree(object, parent = nil)
          self.change_tree do
            self.clear unless parent
            self.fill_model(object, parent)
          end
        end

        protected
        def fill_model(object, parent = nil)
          @object = object unless parent # Remember to which object we are pointing
          DEFAULT_DESCRIBER.show_empty_sections = @show_empty
          DEFAULT_DESCRIBER.show_methods = @show_methods
          DEFAULT_DESCRIBER.show_state = @show_state
          DEFAULT_DESCRIBER.describe(object, GTKDescriptionFactory.new(self, parent))
        end
        
        protected
        def rebuild_tree
          update_tree(@object)
        end
      end
      
      class ObjectBrowserWindow < Dialog
        
        TOGGLE_EMPTY_SECTIONS = 1
        TOGGLE_STATE = 2
        TOGGLE_METHODS =  3

        def initialize(object)
          super("Object Browser for Ruby", nil, 
                MODAL|NO_SEPARATOR,
                ['Show/Hide Empty Entrys', TOGGLE_EMPTY_SECTIONS],
                ['Show/Hide State', TOGGLE_STATE],
                ['Show/Hide Methods', TOGGLE_METHODS],
                [Gtk::Stock::QUIT, RESPONSE_CLOSE])

          hbox = Gtk::HBox.new()
          vbox.add(hbox)
          
          classbrowser = ClassBrowser.new(::ObjectBrowser::create_class_tree(), object)
          hbox.add(Gtk::ScrolledWindow.new.add(classbrowser))
          objectbrowser = ObjectTreeView.new(object)
          hbox.add(Gtk::ScrolledWindow.new.add(objectbrowser))
          
          classbrowser.on_object_selected do | object, iter | objectbrowser.update_tree(object) end
          
          signal_connect(:response) do |widget, response|
            case response
            when TOGGLE_EMPTY_SECTIONS: objectbrowser.show_empty = !objectbrowser.show_empty
            when TOGGLE_STATE: objectbrowser.show_state = !objectbrowser.show_state
            when TOGGLE_METHODS: objectbrowser.show_methods = !objectbrowser.show_methods
            when RESPONSE_CLOSE: destroy; Gtk.main_quit
            end
          end
          self.show_all    
        end
      end

      def browse(object)
        ::Gtk.init
        win = ObjectBrowserWindow.new(object).set_default_size(400, 400).show_all
        ::Gtk.main
      end

      class GTKDescriptionFactory < ObjectBrowser::UI::DescriptionFactory
        def initialize(objectbrowser, parent)
          @objectbrowser = objectbrowser
          @parent = parent
        end
        
        def add(type, text, object = nil, additional = '')
          #raise
          result = self.class.new(@objectbrowser, node = @objectbrowser.insert_node(@parent, type, text, additional, object))
          @objectbrowser.model.append(node) if object
          result
        end
        
        def add_section(type, text)
          add(type, text)
        end
      end
      extend self
    end
  end
  
  DEFAULT_DESCRIBER = Describer.new()
end
