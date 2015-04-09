
# ruby quiz #67 - knowledge.rb
#
# Jeremy Hinegardner

class Module

    def _make_attribute(name,value=nil)
        at = "@#{name}"
        sym = at.to_sym
        name_init = "_#{name}_init"

        if value.respond_to?("call") then
            define_method(name_init,value) 
        end     

        define_method(name) do
            if not self.instance_variables.include?(at) then
                initial_value = value 
                if self.methods.include?(name_init) then
                   initial_value = self.send(name_init)
                end     
                self.instance_variable_set(sym,initial_value)
            end     
            self.instance_variable_get(sym) 
        end     

        define_method("#{name}=") { |val|  self.instance_variable_set(sym,val) }
        define_method("#{name}?") { not [false, nil].include?(self.instance_variable_get(sym)) }
    end

    def attribute(*args, &block) 
        args.each do |arg| 
            if arg.kind_of?(Hash) then
                arg.each_pair do |k,v|
                    if block_given? then
                        _make_attribute(k,block)
                    else    
                        _make_attribute(k,v)
                    end     
                end     
            else    
                _make_attribute(arg,block)
            end     
        end     
    end
end

