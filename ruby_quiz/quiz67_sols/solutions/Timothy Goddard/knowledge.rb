class Module
  def attribute(*arguments, &block)
    # This will store attribute names for adding writers and testers
    attributes = []

    # Iterate over arguments, defining a getter function and adding each attribute to the attributes list.
    arguments.each do |argument|
      if argument.is_a? Hash # Defaults from hash values
        # Our argument is a hash. Iterate over the hash, treating keys as attributes and values as defaults.
        argument.each do |attribute, default|
          attributes << attribute.to_s

          # Define getter with fixed default
          define_method((attribute).to_sym) do
            return default unless instance_variables.include?('@' + attribute.to_s)
            self.instance_variable_get('@' + attribute.to_s)
          end
        end # argument.each
      elsif block # Default from block
        attributes << argument.to_s

        # Our default is a block which should be instance_evaled to get a default value.
        define_method((argument).to_sym) do
          return instance_eval(&block) unless instance_variables.include?('@' + argument.to_s)
          self.instance_variable_get('@' + argument.to_s)
        end
      else # No default
        attributes << argument.to_s
        define_method((argument).to_sym) do
          self.instance_variable_get('@' + argument.to_s)
        end
      end # if argument.is_a? Hash ... elsif block ... end
    end # arguments.each

    # Iterate over the attributes, defining our writer and tester methods.
    attributes.each do |attribute|
      # Define the writer.
      attr_writer attribute.to_sym

      # Define the tester
      define_method((attribute + '?').to_sym) do
        self.send(attribute) ? true : false
      end
    end # attributes.each
  end # def attribute
end # class Module
