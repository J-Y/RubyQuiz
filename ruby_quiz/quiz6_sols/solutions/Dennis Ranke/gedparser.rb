#!/usr/bin/env ruby

require 'CGI'

class String
  def indent(width)
    map {|line| ' ' * width + line.chomp}.join("\n")
  end
end

class Node
  def initialize(type, value)
    @type = type
    @value = CGI.escapeHTML(value)
    @children = []
  end

  def <<(child)
    @children << child
  end

  def to_xml
    children = @children.map{|c| c.to_xml}.join("\n").indent(2)
    if @type[0] == ?@
      return "<%s id=\"%s\">\n%s\n</%s>" %
        [@value.downcase, @type, children, @value.downcase]
    elsif children.empty?
      return "<%s>%s</%s>" % [@type.downcase, @value, @type.downcase]
    else
      if @value.empty?
        return "<%s>\n%s\n</%s>" %
          [@type.downcase, children, @type.downcase]
      else
        return "<%s value=\"%s\">\n%s\n</%s>" %
          [@type.downcase, @value, children, @type.downcase]
      end
    end
  end
end

if ARGV.size != 2
  puts "Usage: gedparser.rb [input.ged] [ouput.xml]"
  exit
end

root = []
stack = [root]
File.readlines(ARGV[0]).each do |line|
  line = line.strip
  depth, type, value = line.split(/\s+/, 3)
  next unless type
  value ||= ''
  node = Node.new(type, value)
  stack[depth.to_i] << node
  stack[depth.to_i + 1] = node
end

xml = root.map {|node| node.to_xml}.join("\n")
xml = "<gedcom>\n" + xml.indent(2) + "\n</gedcom>"

File.open(ARGV[1], 'w') {|f| f.puts xml}
