class Module
  def attribute(a,&blk)
    a,val = a.to_a[0] if a.kind_of? Hash
    attr_accessor a
    define_method(a+'?') { !!send(a) }
    define_method(a) {
      if instance_variables.include?('@'+a)
        instance_variable_get('@'+a)
      else
        val || instance_eval(&blk)	
      end
    } if val || blk
  end
end
