class Module;def attribute(s,*r,&b);attribute(*r,&b) if r.any? ;(Hash===s)?
(s.each {|s,d|attribute(s,&(b||lambda{d}))}):(define_method(s){
instance_variables.include?("@"+s)?instance_variable_get("@"+s):(b&&
instance_eval(&b)||nil)};attr_writer(s);alias_method(s+"?",s));end;end
