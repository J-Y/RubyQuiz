require 'yaml'
require 'ostruct'

class << YAML::DefaultResolver
  alias_method :_node_import, :node_import
  def node_import(node)
    o = _node_import(node)
    o.is_a?(Hash) ? OpenStruct.new(o) : o
  end
end
