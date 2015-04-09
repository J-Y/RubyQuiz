class Module
  def attribute(arg, val=nil, &blk)
    if arg.is_a?(Hash)
      arg.each{|k,v| attribute(k,v)}
      return
    end
    define_method(arg) do ||
      if instance_variables.include?("@#{arg}")
        instance_variable_get("@#{arg}")
      else
        blk ? instance_eval(&blk) : val
      end
    end
    define_method("#{arg}?"){|| !send(arg).nil?}
    attr_writer(arg)
  end
end
