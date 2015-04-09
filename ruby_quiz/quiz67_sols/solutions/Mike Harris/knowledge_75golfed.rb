module Attribute75PercentGolfed; def attribute(a, &b)
 return attribute(a.keys[0]) { a.values[0] } if a.class == Hash
 define_method(a) { block_given? && !instance_eval("defined? "+"@"+a) ?
   send(a+"=",instance_eval(&b)):instance_variable_get("@"+a) }
 define_method(a+"?") { !!send(a) } && attr_writer(a); end; end
