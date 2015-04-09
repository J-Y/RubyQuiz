class Hash
 def to_os
   os = OpenStruct.new
   each {|key,val|
     key = '_'+key.to_s if !key.to_sym ||os.methods.include?(key.to_s)
     key = key.gsub(/[!?]/,'_')
     if val.object_id!=self.object_id
       os.send(key.to_s+'=', val.respond_to?(:to_os) ? val.to_os : val )
     end
   }
   os
 end
end
