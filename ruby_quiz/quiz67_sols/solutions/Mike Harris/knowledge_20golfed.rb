module Attribute20PercentGolfed
 def attribute(arg, &b)
   return attribute(arg.keys[0]) { arg.values[0] } if arg.class == Hash
   define_method(arg) do
     init = block_given? && !instance_eval("defined? "+"@"+arg)
     init ? send(arg+"=",instance_eval(&b)) : instance_variable_get("@"+arg)
   end
   define_method(arg+"?") { !!send(arg) }
   attr_writer(arg)
 end
end
