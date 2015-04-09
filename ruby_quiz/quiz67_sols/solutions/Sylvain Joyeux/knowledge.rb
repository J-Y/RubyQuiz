class Module
    def attribute(*attr_def, &init)
        attr_def = attr_def[0..-2] + attr_def.last.to_a if Hash === attr_def.last
        attr_def.each do |name, defval|
            by_object = Hash.new
            define_method(name) { defval || ( by_object[object_id] ||= instance_eval(&init) if init ) }
            define_method("#{name}?") { send(name) }
            
            define_method("#{name}=") { |value| 
                (class << self; self end).instance_eval { attr_accessor name }
                instance_variable_set("@#{name}", value)
            }
        end
    end
end

