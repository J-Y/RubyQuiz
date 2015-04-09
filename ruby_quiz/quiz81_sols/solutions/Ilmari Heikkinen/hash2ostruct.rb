class Hash
 def method_missing(mn,*a)
   mn = mn.to_s
   if mn =~ /=$/
     super if a.size > 1
     self[mn[0...-1]] = a[0]
   else
     super unless has_key?(mn) and a.empty?
     self[mn]
   end
 end
end
