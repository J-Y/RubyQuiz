def attribute(arg,&b)
  # Allow multiple attributes to be set and defined.
  attribute(*rest,&b) if rest.any?

  # The name of the attribute.
  name = (arg.is_a?(Hash) ? arg.keys[0] : arg).to_s

  # p holds all the attributes for each object.
  # This is wasteful since in real use, this would cause
  # Each object that's set an attribute to be kept in
  # memory.
  p    = Hash.new( arg.is_a?(Hash) ?  arg[name] :  nil  )

  # The only method I define: It takes 1 or more arguments.
  # If it's given an argument, it assigns. In all cases,
  # It returns.
  fun  = lambda { |*args|
    # Assign if necessary.
    p[self] = *args unless args.empty?
    # If it's been assigned, or there's no block, return
    # Its saved value (Or Hash's default)
    (p.include?(self) or !b) ? p[self] : instance_eval(&b)
  }

  # Assign that method to all 3 methods we need.
  ['','?','='].each { |ch| define_method(name+ch,&fun) }
end
