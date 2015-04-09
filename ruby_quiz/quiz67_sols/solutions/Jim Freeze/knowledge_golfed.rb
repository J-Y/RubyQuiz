class Module
  def attribute(*parms, &block)
    return parms[0].each { |p,v| attribute(p) {v} } if parms[0].kind_of?(Hash)
    parms.each { |parm|
      define_method("__#{parm}__", block) unless block.nil?
      class_eval %{attr_writer :#{parm}
        def #{parm};defined?(@#{parm}) ? @#{parm} : __#{parm}__;end
        def #{parm}?;(defined?(@#{parm}) || defined?(__#{parm}__)) && !#{parm}.nil?;end}}
  end
end
