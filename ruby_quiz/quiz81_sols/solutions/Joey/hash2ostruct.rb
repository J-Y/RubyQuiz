class Hash
 def to_ostruct
   copy = {}
   each do |(key,value)|
     if value.class == Hash
       copy[key] = value.to_ostruct
     else
       copy[key] = value
     end
   end
   OpenStruct.new(copy)
 end
end
