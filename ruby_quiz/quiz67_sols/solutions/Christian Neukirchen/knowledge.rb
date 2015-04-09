class Module
  def attribute(a, &block)
    if a.kind_of? Hash
      a, default = a.to_a.first
    else
      default = nil
    end

    a = a.to_sym
    ivar = "@#{a}"

    define_method(a) {
      if instance_variables.include? ivar
        instance_variable_get ivar
      else
        block ? instance_eval(&block) : default
      end
    }
    define_method("#{a}=") { |v| instance_variable_set ivar, v }
    define_method("#{a}?") { !!__send__(a) }
  end
end
