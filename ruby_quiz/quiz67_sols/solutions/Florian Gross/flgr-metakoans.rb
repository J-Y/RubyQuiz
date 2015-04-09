class Module
  def attribute(name, &block)
    name, default = *name.shift if name.is_a?(Hash)
    default_lambda = block || lambda { default }
    ivar = "@#{name}"

    define_method(:"#{name}=") do |new_value|
      instance_variable_set(ivar, new_value)
    end

    define_method(name) do
      if instance_variables.include?(ivar) then
        instance_variable_get(ivar)
      else
        instance_eval(&default_lambda)
      end
    end

    alias_method(:"#{name}?", name)
  end
end
