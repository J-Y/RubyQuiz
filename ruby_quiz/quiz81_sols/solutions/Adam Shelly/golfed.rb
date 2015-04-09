require 'yaml'
require 'ostruct'
class Hash
 def to_os
   o=OpenStruct.new
   each{|k,v|o.send(k.to_s+'=',v.respond_to?(:to_os) ? v.to_os : v)}
   o
 end
end

if __FILE__ == $0
 p data=YAML::load(ARGF.read).to_os
end
