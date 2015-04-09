def attribute(*definition, &block)
  raise "Name missing when creating attribute" unless definition.length > 0
  definition.each do |entry|
    if entry.respond_to?(:to_hash)
      entry.to_hash.each_pair { |key, value| insert_attribute(key, value, block) }
    else
      insert_attribute(entry, nil, block)
    end
  end
end

def insert_attribute(name, value, block)
  default_value = block ? "instance_eval(&block)" : "value"
  begin
    attr_writer name.to_s
    eval("define_method(:#{name}) { return @#{name} if defined? @#{name}; @#{name} = #{default_value}}")
    eval("define_method(:#{name}?) { self.#{name} != nil }") # this could also simply alias the getter and still pass.
  rescue SyntaxError
    raise "Illegal attribute name '#{name}'"
  end
end
