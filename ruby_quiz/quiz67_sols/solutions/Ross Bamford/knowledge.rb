class Module
  # call-seq:
  #   attribute :a                                   -> true
  #   attribute :a, :c => 45, :d => 'stuff'          -> true
  #   attribute(:a) { || default }                   -> true
  #   attribute(:a, :b, :c => 4) { || default a, b } -> true
  def attribute(*args, &blk)
    args.inject({}) { |hsh,arg|
      (arg.respond_to?(:to_hash) ? hsh.merge!(arg) : hsh[arg] = nil) ; hsh
    }.each { |sym, default|
      ivar = :"@#{sym}"
      define_method(sym) do
        if instance_variables.include? ivar.to_s
          instance_variable_get(ivar)
        else
          instance_variable_set(ivar, default || (instance_eval &blk if blk))
          # Ruby 1.9:                            (instance_exec(sym, &blk) if blk))
        end
      end
      # define_method("#{sym}?") { instance_variable_get(ivar) ? true : false }
      alias_method "#{sym}?", sym
      attr_writer sym
    }.any?
  end
end
