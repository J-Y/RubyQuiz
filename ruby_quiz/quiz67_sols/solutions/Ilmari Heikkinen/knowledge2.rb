def attribute(arg,&b)
  attribute(*rest,&b) if rest.any?
  name = (arg.is_a?(Hash) ? arg.keys[0] : arg).to_s
  p    = Hash.new( arg.is_a?(Hash) ?  arg[name] :  nil  )
  fun  = lambda { |*args|
    p[self] = *args unless args.empty?
    (p.include?(self) or !b) ? p[self] : instance_eval(&b)
  }
  ['','?','='].each { |ch| define_method(name+ch,&fun) }
end
