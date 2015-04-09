#!/usr/local/bin/ruby -w

class Module
  def attribute( name, &block )
    if name.is_a? Hash
      name.each do |attr_name, default|
        define_method(attr_name) do
          if instance_variables.include?("@#{attr_name}")
            instance_variable_get("@#{attr_name}")
          else
            default
          end
        end
        
        define_method("#{attr_name}=") do |value|
          instance_variable_set("@#{attr_name}", value)
        end

        define_method("#{attr_name}?") do
          send(attr_name) ? true : false
        end
      end
    elsif block
      define_method(name) do
        if instance_variables.include?("@#{name}")
          instance_variable_get("@#{name}")
        else
          instance_eval(&block)
        end
      end
      
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end

      define_method("#{name}?") do
        send(name) ? true : false
      end
    else
      define_method(name) do
        instance_variable_get("@#{name}")
      end
      
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end

      define_method("#{name}?") do
        send(name) ? true : false
      end
    end
  end
end
