class Object
 def self.abbrev(*args)
   module_eval <<-EOS
   @@abbrevs ||= []
   @@abbrevs += args

   def method_missing(m)
     # abbrev targets themselves are not supposed to be expanded
     raise NoMethodError if @@abbrevs.include?(m)

     # which abbrev targets could match m, and which of those correspond to methods?
     matches = @@abbrevs.select do |sym|
       sym.to_s.index(m.to_s) == 0 && methods.include?(sym.to_s)
     end

     case matches.size
       when 0
         raise NoMethodError
       when 1
         self.send(matches.first)
       else
         # multiple matches, pass them back to the user
         return matches if $TESTING
         puts matches.join(" ")
     end
   end
   EOS

 end
end
