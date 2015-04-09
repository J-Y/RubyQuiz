require 'ostruct'
require 'rbyaml'

class TrueClass; def to_sym; :true end; end
class FalseClass; def to_sym; :false end; end

RbYAML.add_builtin_ctor("map") {|ctor,node|
  OpenStruct.new(ctor.construct_mapping(node))
}

RbYAML.load(data)
