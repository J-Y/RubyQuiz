class Module; def attribute(name, &block)
  name, default = *name.shift if name.is_a?(Hash)
  ivar, default_lambda = "@#{name}", block || lambda { default }
  define_method(:"#{name}=") { |val| instance_variable_set(ivar, val) }
  define_method(name) { instance_variables.include?(ivar) ?
    instance_variable_get(ivar) : instance_eval(&default_lambda) }
  alias_method(:"#{name}?", name)
end; end
