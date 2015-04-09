class Module
  def attribute(sym, *more, &blk)
    attribute(*more, &blk) unless more.empty?
    if sym.is_a?(Hash)
      sym.each_pair { |sym, dval| attribute(sym, &(blk || lambda { dval })) }
    else
      iname = "@#{sym}"
      define_method(sym) do
        if instance_variables.include?(iname)
          instance_variable_get(iname)
        else
          if blk then instance_eval(&blk) end
        end
      end
      attr_writer(sym)
      alias_method("#{sym}?", sym)
    end
  end
end
