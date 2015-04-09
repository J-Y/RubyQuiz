require 'delegate'

class SerializableProc < DelegateClass(Proc)
  attr_reader :__code

  def initialize(code)
    @__code = code.lstrip
    super eval("lambda { #@__code }")
  end

  def marshal_dump; @__code; end
  def marshal_load(code); initialize code; end

  def to_yaml
    Object.instance_method(:to_yaml).bind(self).call
  end

  def to_yaml_properties; ["@__code"]; end
  def to_yaml_type; "!ruby/serializableproc"; end
end

# .oO(Is there no easier way to do this?)
YAML.add_ruby_type( /^serializableproc/ ) { |type, val|
  type, obj_class = YAML.read_type_class( type, SerializableProc )
  o = YAML.object_maker( obj_class, val )
  o.marshal_load o.__code
}
