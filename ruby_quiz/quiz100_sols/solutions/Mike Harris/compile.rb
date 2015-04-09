class Compiler
 def self.compile(s)
   eval(s.gsub(/(\d+)([^\d])/,'\1.bc\2').gsub(/([^\d])(\d+)$/,'\1\2.bc'))
 end
end

class Fixnum
 def bc
   lead,pt = ( (-2**15...2**15)===self ? [1,'n'] : [2,'N'] )
   [lead].concat([self].pack(pt).unpack('C*'))
 end
end

class Array
 {:+ => 10,:- => 11,:* => 12,:** => 13,:/ => 14,:% => 15}.each do |op,code|
   define_method(op) { |x| self.concat(x).concat([code]) }
 end
