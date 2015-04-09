require 'gtk2'

DEFAULT_OBJECTBROWSER_ROOT = self

class Object
  alias :pre_objbrowser_inspect :inspect
  def inspect
    result = pre_objbrowser_inspect
    result = $1 + " ...>" if result =~ /^(#<.*?:0x\w+) /
    result
  end
end

module ObjectBrowser

  def browse( root = DEFAULT_OBJECTBROWSER_ROOT )
    Interface.new( root ).display_and_wait
  end
  module_function :browse

  class Interface
    def initialize( root = DEFAULT_OBJECTBROWSER_ROOT )
      @root = root
      Gtk.init
    end

    def display
      window = Window.new( @root )
      window.show_all
    end

    def display_and_wait
      display
      wait
    end

    def wait
      Gtk.main
    end
  end

  class Window < Gtk::Window
    OBJECT = 1
    CLASS  = 2
    INSTANCE_VARS = 3
    PUBLIC_METHODS = 4
    PROTECTED_METHODS = 5
    PRIVATE_METHODS = 6
    CLASS_VARS = 7
    CONSTANTS = 8
    SUPERCLASS = 9
    STRING = 10
    INSTANCE_METHODS = 11

    LABEL = 0
    TYPE  = 1
    REF   = 2

    def initialize( root )
      super( Gtk::Window::TOPLEVEL )

      signal_connect "delete_event", &method( :on_delete )
      signal_connect "destroy", &method( :on_destroy )

      vbox = Gtk::VBox.new
      add(vbox)

      pane = Gtk::VPaned.new
      vbox.add pane

      sw = Gtk::ScrolledWindow.new
      sw.set_policy *[Gtk::POLICY_AUTOMATIC]*2
      sw.shadow_type = Gtk::SHADOW_IN
      pane.add sw

      @model = Gtk::TreeStore.new( String, Integer, Integer )
      add_node( nil, root )

      @tree = Gtk::TreeView.new( @model )
      @tree.set_size_request -1, 400

      renderer = Gtk::CellRendererText.new

      col = Gtk::TreeViewColumn.new( "Data", renderer )
      col.set_cell_data_func renderer, &method( :on_cell_render )

      @tree.append_column col
      @tree.expand_row Gtk::TreePath.new( "0" ), false

      @tree.signal_connect "row_expanded", &method( :on_row_expanded )

      sw.add @tree

      sw = Gtk::ScrolledWindow.new
      sw.set_policy *[Gtk::POLICY_AUTOMATIC]*2
      sw.shadow_type = Gtk::SHADOW_IN
      pane.add sw

      @text = Gtk::TextView.new
      sw.add @text

      set_default_size 650, 500
    end

    def on_delete( widget, event )
      false
    end

    def on_destroy( widget )
      Gtk.main_quit
    end

    def on_cell_render( c, r, m, i )
      case i[TYPE]
        when OBJECT
          obj = ObjectSpace._id2ref( i[REF].to_i )
          r.text = "#{i[LABEL]}#{obj.inspect}"
        when CLASS, SUPERCLASS
          obj = ObjectSpace._id2ref( i[REF].to_i )
          r.text = "#{i[LABEL]} #{obj.name}"
        else
          r.text = i[LABEL]
      end
    end

    def on_row_expanded( widget, iter, path )
      unless iter.first_child[LABEL]
        case iter[1]
          when OBJECT, CLASS, SUPERCLASS then
            obj = ObjectSpace._id2ref( iter[REF].to_i )
            add_node iter, obj, iter.first_child
          when INSTANCE_VARS then
            obj = ObjectSpace._id2ref( iter.parent[REF].to_i )
            initialize_vars_list( obj, iter, obj.instance_variables.sort,
              :instance_variable_get )
          when PUBLIC_METHODS then
            obj = ObjectSpace._id2ref( iter.parent[REF].to_i )
            initialize_methods_list( obj, iter, obj.public_methods(false).sort )
          when PROTECTED_METHODS then
            obj = ObjectSpace._id2ref( iter.parent[REF].to_i )
            initialize_methods_list( obj, iter,
              obj.protected_methods(false).sort )
          when PRIVATE_METHODS then
            obj = ObjectSpace._id2ref( iter.parent[REF].to_i )
            initialize_methods_list( obj, iter,
              obj.private_methods(false).sort )
          when INSTANCE_METHODS then
            obj = ObjectSpace._id2ref( iter.parent[REF].to_i )
            initialize_methods_list( obj, iter,
              obj.instance_methods(false).sort, true )
          when CLASS_VARS then
            obj = ObjectSpace._id2ref( iter.parent[REF].to_i )
            initialize_vars_list( obj, iter,
              obj.class_variables.sort, :class_eval )
          when CONSTANTS then
            obj = ObjectSpace._id2ref( iter.parent[REF].to_i )
            constants = obj.constants
            if obj.respond_to?(:superclass) && obj.superclass
              constants = constants - obj.superclass.constants
            end
            initialize_vars_list( obj, iter, constants.sort, :const_get )
          else
            raise "don't know what to do with row of type #{iter[TYPE]}"
        end
      end

      path_str = iter.path.to_s + ":" + ( iter.n_children - 1 ).to_s
      path = Gtk::TreePath.new( path_str )

      @tree.scroll_to_cell( path, nil, true, 1.0, 0 )
    end

    def add_node( parent, object, node=nil )
      unless node
        node = add_row( parent, "", object, OBJECT, false )
        add_row( node, "class", object.class, CLASS )
      else
        add_row( parent, "class", object.class, CLASS, true, node )
        node = parent
      end

      if object.is_a?( Module )
        if object.respond_to?(:superclass) && object.superclass
          add_row( node, "extends", object.superclass, SUPERCLASS )
        end
        add_row_unless_empty(
          object.class_variables, node, "Class Variables", CLASS_VARS )

        constants = object.constants
        if object.respond_to?(:superclass) && object.superclass
          constants = constants - object.superclass.constants
        end

        add_row_unless_empty( constants, node, "Constants", CONSTANTS )
        add_row_unless_empty( object.instance_methods(false), node,
          "Instance Methods", INSTANCE_METHODS )
      end

      add_row_unless_empty( object.instance_variables, node,
        "Instance Variables", INSTANCE_VARS )
      add_row_unless_empty( object.public_methods(false), node,
        "Public Methods", PUBLIC_METHODS )
      add_row_unless_empty( object.protected_methods(false), node,
        "Protected Methods", PROTECTED_METHODS )
      add_row_unless_empty( object.private_methods(false), node,
        "Private Methods", PRIVATE_METHODS )

      node
    end

    def add_row_unless_empty( list, node, name, type, add_empty=true )
      unless list.empty?
        summary = list.sort.join( "," )
        summary = summary[0,60] + "..." if summary.length > 63
        add_row( node, "#{name} (#{summary})", nil, type )
      end
    end

    def add_row( parent, label, value, type, add_empty=true, node=nil )
      node = @model.append( parent ) unless node

      node[ LABEL ] = label
      node[ TYPE ] = type
      node[ REF ] = value.object_id

      @model.append( node ) if add_empty

      node
    end

    def initialize_methods_list( obj, iter, list, instance=false )
      node = iter.first_child
      list.each do |item|
        if instance
          method = obj.instance_method( item.to_sym )
        else
          method = obj.method( item.to_sym )
        end
        add_row iter, item + "(#{method.arity})", obj, STRING, false, node
        node = nil
      end
    end

    def initialize_vars_list( obj, iter, list, message )
      node = iter.first_child
      list.each do |item|
        value = obj.__send__( message, item )
        add_row iter, "#{item}=", value, OBJECT, true, node
        node = nil
      end
    end
  end

end

if __FILE__ == $0
  @obj = ObjectBrowser::Interface.new
  @obj.display_and_wait
end
