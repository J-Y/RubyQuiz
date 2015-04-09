class Module
  def attribute( attrib, &block )
    if attrib.is_a? String
    then
      if (block_given?) then
        property_with_block_init(attrib, block )
      else
        property(attrib)
      end
    elsif attrib.is_a? Hash
      attrib.each_pair do
        |property, value|
        property_with_default( property, value )
      end
    else
    end
  end
  def property(name)
    self.module_eval %Q{
      attr_accessor name.to_sym
      def #{name}?
        not not #{name}
      end
    }
  end
  def property_with_block_init(name, block)
    property(name)
    self.module_eval do
      define_method( name.to_sym ) do
        if self.instance_variables.member?("@" + name) then
          self.instance_variable_get("@" + name)
        else
          instance_eval( &block )
        end
      end
    end
  end
  def property_with_default( name, value )
    property(name)
    self.module_eval do
      define_method( name.to_sym ) do
        if self.instance_variables.member?("@" + name) then
          self.instance_variable_get("@" + name)
        else 
          value
        end
      end
    end
  end
end
