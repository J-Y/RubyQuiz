class Module
  def attribute(x, &block)
    name, value = x.to_a[0] # produces a warning is x is a symbol
    ivar = "@#{name}"
    define_method(name) do
      if instance_variables.include?(ivar)
        instance_variable_get(ivar)
      else
        value || (instance_eval &block if block)
      end
    end
    attr_writer name
    define_method("#{name}?") { !!send(name) }
  end
end
