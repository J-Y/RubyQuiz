# Register Methods that inspect certain kinds of objects. 
# Methods take:
# - Object
# - Description Factory which depends on the gui and has methods as follows
#   - description=: Textual description of the object
#   - id=:          Id of the object
#   - add_section(title):  creates a new section and returns a section factory object
#
#   Section factory objects are used to describe sections of the object description.
#
#   Sections contain other sections, leaf entries, and key=value entries, where if the value is another object
#   it can be expanded later by calling the describe_object methods
#
#   Each section entry consists of the type, the content, additional content to show in a less prominent position,
#   and eventually the object to be expanded next.


module ObjectBrowser

  # Class that holds a collection of Describers for different objects. Each
  # Describer should implement a #describe(options, object, description_factory),
  # #display_string(options, object, length), and a ... function.
  #
  # Additionally it needs a #applicable?(object) function and a #importance()
  # function that describes its own behaviour.
  class Describer
    attr_accessor :show_methods, :show_state, :show_empty_sections

    # Initialize. By default initializes with all describers in the module
    # ObjectBrowser.  A describer is identified by containing the word Describer
    # and responding to applicable?, importance and describe    
    def initialize(describers =  ObjectBrowser.constants.grep(/Describer/).map{|cn| ObjectBrowser.const_get(cn)}.
                     select{|c| im = c.instance_methods;
                     (im.include?'applicable?') and (im.include?'importance') and (im.include?'describe')})
      @describers = []
      describers.each{ |d| register(d.new) }      
      self.show_methods = true
      self.show_state = true
      self.show_empty_sections = true
    end

    def register(describer)
      @describers << describer
      @describers = @describers.sort_by{|d| -d.importance}
    end

    def describe(object, description_factory)
      @describers.each do | d |
        if d.applicable?object
          d.describe(self, object, description_factory)
          return true
        end
      end
      raise "No applicable descriptor found"
    end

    def display_string(object, length = nil)
      @describers.each do | d |
        return d.display_string(self, object, length) if d.applicable?object
      end
      raise "No applicable descriptor found"
    end
  end
 
  # Hold object describer methods for a kind of objects. Call #describe with an
  # object and a description factory to create a description.  The description
  # factory given depends on the GUI used.
  #
  # The ObjectDescriber can be extended or descended to implement descriptions of custom objects.
  #
  # Needs a #describe(options, object, description_factory), a #applicable?(object) function and a #importance() function.
  class ObjectDescriber

    def importance() -100 end

    def applicable?(object)
      object.is_a?Object
    end

    def describe(options, object, description)
      add_constants(options, object, description)
      add_instance_variables(options, object, description)
      add_class_variables(options, object, description)
      add_methods(options, object, description)
      add_modules(options, object, description)
    end

    # TODO: Make this also extendable using a mechanism similar to the one used in this class
    def display_string(options, object, length = nil)
      result = (object.respond_to?:to_s) ? object.to_s : object.inspect
      return result[0..length-4] + '...' if length and result.length > length
      return result
    end

    protected
    # Produce a one-line description of what this object is.
    def short_description(object)
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

    protected
    def add_methods(options, object, description)
      return unless options.show_methods
      
      [['Public Methods', :public_methods],
        ['Protected Methods', :protected_methods],
        ['Private Methods', :private_methods],
        ['Public Instance Methods', :public_instance_methods],
        ['Protected Instance Methods', :protected_instance_methods],
        ['Private Instance Methods', :private_instance_methods]].each do | title, list_method |

        next unless object.respond_to?list_method

        if options.show_empty_sections || !object.send(list_method, true).empty?
          
          section = description.add_section(:h1, title)

          methods = object.send(list_method, false).sort
          if options.show_empty_sections || !methods.empty?
            method_type_section = section.add_section(:h2, 'Own Methods')
            methods.each do | method |
              arity = (object.method(method).arity rescue nil) || (object.instance_eval("self.method('#{method}').arity") rescue nil) || -99
              $stderr.puts "Could not evaluate self.method('#{method}').arity for #{object.inspect}." unless arity
              method_type_section.add(:method, "#{method}(#{args_from_arity(arity)})")
            end
          end

          methods = (object.send(list_method, true) - object.send(list_method, false)).sort
          if options.show_empty_sections || !methods.empty?
            method_type_section = section.add_section(:h2, 'Inherited Methods')
            methods.each do | method |
              arity = (object.method(method).arity rescue nil) || (object.instance_eval("self.method('#{method}').arity") rescue nil) || -99
              $stderr.puts "Could not evaluate self.method('#{method}').arity for #{object.inspect}." unless arity
              method_type_section.add(:method, "#{method}(#{args_from_arity(arity)})")
            end
          end
        end
      end
    end

    def add_instance_variables(options, object, description)
      return unless options.show_state
      return unless object.respond_to?:instance_variables
      
      if options.show_empty_sections || !object.instance_variables.empty?     
        section = description.add_section(:h1, 'Instance Variables')
        object.instance_variables.each do | varname |
          value = object.instance_variable_get(varname)
          section.add(:variable, "#{varname} = #{options.display_string(value)}", value, short_description(value))
        end
      end    
    end

    def add_class_variables(options, object, description)
      return unless options.show_state
      return unless object.respond_to?:class_variables
      
      if options.show_empty_sections || !object.class_variables.empty?
        description.add_section(:h1, 'Class Variables')
        object.class_variables.each do | varname |
          value = object.class_eval(varname)
          section.add(:variable, "#{varname} = #{options.display_string(value)}", value, short_description(value))
          model.append(node)
        end
      end    
    end
    
    def add_modules(options, object, description)
      return unless options.show_methods
      return unless object.respond_to?:included_modules
      
      if options.show_empty_sections || !object.included_modules.empty?
        section = description.add_section(:h1, 'Included Modules')
        object.included_modules.each do | mod | section.add(:module, mod, mod) end
      end
    end

    def add_constants(options, object, description)
      return unless options.show_state
      return unless object.respond_to?:constants
      
      if options.show_empty_sections || !object.constants.empty?
        section = description.add_section(:h1, 'Constants')
        object.constants.each do | varname |
          value = object.const_get(varname)
          section.add(:constant, "#{varname} = #{options.display_string(value)}", value, short_description(value))
        end
      end    
    end

    protected
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
    # shorten a string, continuing with ... if it is too long
    def shorten(string, length)
      return string if string.length <= length
      return string[0..length-3] + '...' 
    end

    protected
    # Format a object either as
    def to_simple_str(object)
      object.respond_to?(:to_s) ? object.to_s : "#<#{object.id.to_s(16)}>"
    end
  end

  class NumericDescriber < ObjectDescriber
    def importance() -90 end

    def applicable?(object)
      object.is_a?Numeric
    end
  end

  class HashDescriber < ObjectDescriber
    def importance() -80 end

    def applicable?(object)
      object.is_a?Hash
    end

    # TODO: Make this also extendable using a mechanism similar to the one used in this class
    def display_string(options, object, length = nil)
      if length
        l = length -1
        result = []
        if object.each do | k, v |
            s = "#{options.display_string(k, l)} => #{options.display_string(v, l)}"
            l -= (s.length + 2)
            break false if l < 0
            result << s
          end
          '{' + result.join(', ') + '}'
        else
          '{' + result.join(', ') + '...}'
        end
      else
        '{' + object.map{|k, v| "#{options.display_string(k)} => #{options.display_string(v)}"}.join(', ') + '}'
      end
    end

    def describe(options, object, description)
      add_hash_values(options, object, description)
      add_constants(options, object, description)
      add_instance_variables(options, object, description)
      add_class_variables(options, object, description)
      add_methods(options, object, description)
      add_modules(options, object, description)
    end

    protected
    def add_hash_values(option, object, description)
      return unless option.show_state
      return unless object.respond_to?:each
      section = description.add_section(:h1, 'Content')
      object.each do | key, value |
        cl = section.add(:variable, "#{option.display_string(key)} => #{option.display_string(value)}", nil,
                         "#{short_description(key)} => #{short_description(value)}")
        cl.add(:variable, "Key: #{option.display_string(key)}", key, short_description(key))
        cl.add(:variable, "Value: #{option.display_string(value)}", value, short_description(value))
      end
    end
  end

  class ArrayDescriber < ObjectDescriber
    def importance() -80 end

    def applicable?(object)
      object.is_a?Array
    end

    # TODO: Make this also extendable using a mechanism similar to the one used in this class
    def display_string(options, object, length = nil)
      if length
        l = length -1
        result = []
        if object.each do | v |
            s = options.display_string(v, l)
            l -= (s.length + 2)
            break false if l < 0
            result << s
          end
          '[' + result.join(', ') + ']'
        else
          '[' + result.join(', ') + '...]'
        end
      else
        '[' + object.map{|k, v| options.display_string(v)}.join(', ') + ']'
      end
    end

    def describe(options, object, description)
      add_array_values(options, object, description)
      add_constants(options, object, description)
      add_instance_variables(options, object, description)
      add_class_variables(options, object, description)
      add_methods(options, object, description)
      add_modules(options, object, description)
    end

    protected
    def add_array_values(option, object, description)
      return unless option.show_state
      return unless object.respond_to?:each
      section = description.add_section(:h1, 'Content')
      object.each_with_index do | value, key |
        section.add(:variable, "#{key}: #{option.display_string(value)}", value, "#{short_description(value)}")
      end
    end
  end

  class SymbolDescriber < ObjectDescriber
    def importance() -90 end

    def applicable?(object)
      object.is_a?Symbol
    end

    # TODO: Make this also extendable using a mechanism similar to the one used in this class
    def display_string(options, object, length = nil)
      ":#{object}"
    end
  end

  # Class Tree Nodes. Holds forward pointers from each class to its subclasses and instances.
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

  # Creates a class tree from the classes that are active right now. You can give it a list of classes to exclude. By default it excludes
  # ClassTreeNode objects, ObjectDescriber objects, and DescriptionFactory objects.
  def create_class_tree(classtree = ClassTreeNode.new(Kernel),
                        ignore = [ClassTreeNode, ObjectDescriber, ObjectBrowser, ObjectBrowser::UI, ObjectBrowser::UI::DescriptionFactory])
    ObjectSpace.each_object do | x |
      classnode = classtree
      x.class.ancestors.reverse[1..-1].inject(classtree){ | classnode, klass | classnode.add_class(klass) }.add_object(x)
    end  
    classtree
  end

  extend self
end
