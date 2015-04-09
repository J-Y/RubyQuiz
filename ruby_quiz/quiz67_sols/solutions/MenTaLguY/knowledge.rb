class Module
  def attribute( name, &default_block )
    name, default_value = name.to_a.first if name.is_a? Hash
    default_block ||= proc { default_value }

    ivar = "@#{ name }".to_sym

    define_method name do
      value = instance_variable_get ivar
      unless value or instance_variables.include? ivar.to_s
        instance_variable_set ivar, instance_eval( &default_block )
      else
        value
      end
    end

    define_method "#{ name }=" do |value|
      instance_variable_set ivar, value
    end

    alias_method "#{ name }?", name
  end
end
