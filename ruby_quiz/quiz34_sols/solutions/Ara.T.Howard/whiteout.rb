#!/usr/bin/env ruby
require 'yaml'

this, prog, *paths = [__FILE__, $0, ARGV].flatten.map{|x| File::expand_path x}
usage = "#{ prog } file [files]+"

f = open this, 'r+'
s, pos = f.gets, f.pos until s =~ /^__END__$/
srcs = YAML::load f

if prog == this
  abort usage if paths.empty?
  abort "#{ prog } must be writable" unless File::stat(this).writable?
  paths.each do |path|
    s, b = IO::read(path).split(%r/(^\s*#\s*!.*\n)/o).reverse.first 2
    srcs[path] = s
    open(path,'w'){|o| o.puts b, "require 'whiteout'\n"}
  end
  f.seek pos and f << srcs.to_yaml and f.truncate f.pos
else
  eval srcs[prog]
end

__END__
---
{}
