Module.module_eval do
    def attribute(arg,&block)   # I bow to the impossible


    case when block_given?
      default_value = true
    when Hash === arg
      inst_var_name, default_value = arg.to_a.flatten
    end

    inst_var_name ||= arg
    inst_var = "@#{inst_var_name || arg}"

    define_method inst_var_name do
      if default_value and not instance_variables.member?(inst_var)
        if block_given?
          instance_variable_set inst_var, instance_eval(&block)
        else
          instance_variable_set inst_var, default_value
        end
      end


      instance_variable_get inst_var

    end



    define_method("#{inst_var_name}=") do |v|

      instance_variable_set inst_var, v

    end



    alias_method("#{inst_var_name}?", inst_var_name)

  end

end
