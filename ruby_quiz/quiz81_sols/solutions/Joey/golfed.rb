require 'yaml';require 'ostruct';def h(h)h.map{|k,v|h[k]=Hash\
===v ?h(v):v};OpenStruct.new(h)end;puts h(YAML.load($<.read))
