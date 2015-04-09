module Gedcom
  class ParseError < ArgumentError; end

  class Node < Hash
    attr_accessor :value, :origin, :special_type, :id
    def special?() not @special_type.nil? end

    def initialize(origin = nil)
      @value, @origin = nil, origin
      @as_plain_hash_cache = Hash.new

      super() do |hash, key|
        hash[key] = Array.new
      end
    end

    def hash
      [@value.is_a?(Node) ? :recursive : @value, super].hash
    end

    def ==(other) self.hash == other.hash end

    def replace(other)
      super(other)
      @value, origin = other.value, other.origin
    end

    # YAML detects self-referencing structures by comparing object_ids.
    # as_plain_hash() needs to cache the Hash it creates to make that 
    # check work.
    def as_plain_hash
      if @as_plain_hash_cache.include?(self.hash)
        @as_plain_hash_cache[self.hash]
      else
        result = {}.merge(self)

        result.each do |key, values|
          if values.size == 1 then
            result[key] = values.first
          end
        end

        if not @value.nil? then
          result[:value] = @value
        end

        @as_plain_hash_cache[self.hash] = result
      end
    end
    private :as_plain_hash

    def as_value
      if @value.is_a?(String) and empty? then
        @value
      else
        as_plain_hash
      end
    end

    def to_yaml_type() "!map" end

    def to_yaml(opts = {}) as_value.to_yaml(opts) end
    def inspect() as_value.inspect end
    def pretty_print(q) as_value.pretty_print(q) end

    def to_xml(level = 0)
      require 'cgi'
      indent = "  " * (level + 1)

      result = if @value.is_a?(Node) then
        "#{indent}<ref to=\"#{@value.id}\" />"
      else
        self.map do |tag, nodes|
          nodes.map do |node|
            escaped_value = if node.value.is_a?(String) then
              CGI.escapeHTML(node.value.to_s)
            end
            id_attr = node.id.nil? ? "" : " id=\"#{node.id}\""
            xml_tag = tag.downcase

            if node.value.nil? and node.empty? then
              "#{indent}<#{xml_tag}#{id_attr} />"
            elsif node.empty? and escaped_value then
              "#{indent}<#{xml_tag}#{id_attr}>" + escaped_value + "</#{xml_tag}>"
            else
              if node.value.is_a?(String) and node.value["\n"] then
                "#{indent}<#{xml_tag}#{id_attr}>\n" +
                "#{indent}  #{node.value}\n" +
                node.to_xml(level + 1) + "\n" + 
                "#{indent}</#{xml_tag}>"
              else
                val_attr = node.value.is_a?(String) ? " value=\"#{escaped_value}\"" : ""
                "#{indent}<#{xml_tag}#{id_attr}#{val_attr}>\n" +
                node.to_xml(level + 1) + "\n" + 
                "#{indent}</#{xml_tag}>"
              end
            end
          end.join("\n")
        end.join("\n")
      end

      if level == 0 then
        result = "<gedcom>\n#{result}\n</gedcom>"
      end

      return result
    end
  end

  LineRegexp = /^\s*(\d+)\s+(?:(@\w[^@]*@)\s+)?(\w+)(?:\s+(?:(@\w[^@]*@)|(.+)))?\s*$/

  def parse(data)
    nodes = Node.new(1)
    stack = [nodes]
    node_by_id = Hash.new
    nodes_with_refs = Array.new

    data.each_with_index do |line, index|
      line_no = index + 1

      if md = LineRegexp.match(line) then
        level, id, tag, value_id, value = *md.captures
        level = level.to_i
        value.gsub!("@@", "@") if value

        if level > stack.size - 1 then
          raise(ParseError, "Inconsistent nesting at line #{line_no}")
        elsif level != stack.size - 1 then
          (stack.size - level - 1).times { stack.pop }
        end

        if stack.last.special? then
          raise(ParseError, "Can't create sub node for special node " +
            "of type #{stack.last.special_type} " +
            "(defined at #{stack.last.origin}) at #{line_no}")
        end

        new_node = Node.new(line_no)

        if id and not id.empty? then
          node_by_id[id] = new_node
          new_node.id = id
        end

        if value and not value.empty? then
          new_node.value = value
        elsif value_id and not value_id.empty? then
          nodes_with_refs << new_node
          # id is temporarily stored in value
          new_node.value = value_id
        end

        case tag
          when "CONC", "CONT" then
            new_node.special_type = tag

            if id and not id.empty? then
              raise(ParseError, "#{tag} node can't have id at line #{line_no}")
            end

            str_value = (value and not value.empty?) ? value : value_id
            separator = case tag
              when "CONC" then ""
              when "CONT" then "\n"
            end
            stack.last.value = stack.last.value.to_s + separator + str_value.to_s
        end

        unless new_node.special?
          stack.last[tag] << new_node
        end
        stack << new_node
      elsif line.strip.empty? then
        # Ignore, line contains whitespace only
      else
        raise(ParseError, "Parse error at line #{line_no}")
      end
    end

    nodes_with_refs.each do |node|
      id = node.value
      if node_by_id.include?(id) then
        node.value = node_by_id[id]
      else
        raise(ParseError, "Pointer to undefined node `#{id}' at line #{node.origin}")
      end
    end

    return nodes
  end
  module_function :parse
end

if __FILE__ == $0 then
  data = ARGF.read

  require 'pp'
  puts "Pretty-printed:"
  begin
    pp Gedcom.parse(data)
  rescue SystemStackError
    puts "Sorry, pp blowed up the stack."
  end

  require 'yaml'
  puts "", "As YAML:"
  begin
    y Gedcom.parse(data)
  rescue SystemStackError
    puts "Sorry, YAML blowed up the stack."
  end

  puts "", "As XML:"
  puts Gedcom.parse(data).to_xml
end
