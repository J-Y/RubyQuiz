def attribute(arg,*rest,&b)
  attribute(*rest,&b) if rest.any? # Allow multiple definitions.
  n    = (arg.is_a?(Hash) ? arg.keys[0] : arg).to_s
  b  ||= lambda { arg.is_a?(Hash) ? arg[n] :  nil  }
  attr_writer n
  define_method(n) { instance_variables.include?('@'+n) ? \
      instance_variable_get('@'+n) : instance_eval(&b) }
  define_method(n+'?') { ! [nil,false].include?(send(n)) }
end
