class Module
  def attribute(hash, &block)

    (name, default) = hash.is_a?(Hash) ? [hash.keys[0], hash.values[0]] : [hash, nil]

    define_method("#{name}?") { instance_eval("@#{name} != nil") }

    define_method("#{name}") do
      if !instance_variables.include?( "@#{name}" )
        instance_variable_set("@#{name}", block.nil? ? default : instance_eval(&block))
      else
        instance_variable_get("@#{name}")
      end
    end

    class_eval <<-METHOD
      def #{name}=(value)
        @#{name} = value
      end
    METHOD

  end
end
