class Object
  def attribute(arg, &block)
    name = (arg.class == Hash ? arg.keys[0] : arg)
    define_method(name) do
      first_access_action(arg,&block) unless instance_eval("defined? " + "@" + name)
      instance_variable_get "@" + name
    end
    attr_writer name
    alias_method name+"?",name
  end

  def first_access_action(arg,&block)
    name = (arg.class == Hash ? arg.keys[0] : arg)
    send(name+"=",instance_eval(&block)) if block_given?
    send(name+"=",arg.values[0]) if arg.class == Hash
  end
end
