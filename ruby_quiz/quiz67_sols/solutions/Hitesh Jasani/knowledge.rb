class Module
  def attribute sym, &blk
    name, dval = sym, false
    name, dval = sym.keys.first, sym.values.first if Hash === sym
    if blk
      dval = "def_value_#{sym}".to_sym
      define_method(dval, blk)
    end
    module_eval %( def #{name}; @#{name} ||= #{dval}; end )
    module_eval %( def #{name}=(val); if NilClass === val then @#{name} = lambda{nil}.call; else @#{name} = val; end; end )
    module_eval %( def #{name}?; @#{name} ? true : false ; end)
  end
end
