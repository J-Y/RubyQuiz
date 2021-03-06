#! /usr/bin/ruby
require 'rexml/document'

doc = REXML::Document.new "<gedcom/>"
stack = [doc.root]

ARGF.each_line do |line|
  next if line =~ /^\s*$/

  # parse line
  line =~ /^\s*([0-9]+)\s+(@\S+@|\S+)(\s(.*))?$/ or raise "Invalid GEDCOM"
  level = $1.to_i
  tag = $2
  data = $4

  # pop off the stack until we get the parent
  while (level+1) < stack.size
    stack.pop
  end
  parent = stack.last

  # create XML tag
  el = nil
  if tag =~ /@.+@/
    el = parent.add_element data
    el.attributes['id'] = tag
  else
    el = parent.add_element tag
    el.text = data
  end

  stack.push el
end
doc.write($stdout,0)
puts
