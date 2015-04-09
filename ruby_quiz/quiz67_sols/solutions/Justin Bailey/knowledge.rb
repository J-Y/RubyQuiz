class Object
  def attribute(arg, &block)
    # Determine if we have an initial value for the attribute or not, and put
    # them all into a common form.
    if arg.is_a?(Hash)
      props = arg.collect { |k, v| k }
    else
      # Note this sets the initial value to nil, which is a no-op below, if
      # no block was specified.
      props = [arg]
      arg = { arg => block }
    end

    props.each do |p|
      instance_var, init_meth = "@#{p}".to_sym, "#{p}_init".to_sym

      if (val = arg[p])
        # set up initializer methods for block or given value. Note a
        # method is created for each attribute given that has a value associated
        self.instance_eval do
          if val.is_a?(Proc)
            define_method init_meth, val
          else
            define_method(init_meth) { val }
          end
          # set visibility
          private init_meth
        end
      end

      # define attribute accessor methods
      class_eval do
        attr_writer p.to_sym

        # for first time access, look to appropriate init method, if any and
        # get value. In either case, the instance_variable will be defined after
        # this method if it wasn't before.
        define_method(p.to_sym) do
          unless x = instance_variable_get(instance_var) || val.nil?
            instance_variable_set(instance_var, x = self.send(init_meth))
          end
          x
        end

        # Define query accessor. Only returns true if the instance variable is defined,
        # regardless of its value.
        define_method("#{p}?") do
          ! instance_variable_get(instance_var).nil?
        end
      end
    end
  end
end
