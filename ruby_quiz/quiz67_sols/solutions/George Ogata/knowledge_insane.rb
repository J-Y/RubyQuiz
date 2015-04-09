class Module
  def attribute(a, &b)
    b or return (Hash===a ? a : {a=>nil}).each{|k,v| attribute(k){v}}
    define_method(a){(x=eval("@#{a}")) ? x[0] : instance_eval(&b)}
    define_method("#{a}?"){!send(a).nil?}
    define_method("#{a}="){|v| instance_variable_set("@#{a}", [v])}
  end
end
