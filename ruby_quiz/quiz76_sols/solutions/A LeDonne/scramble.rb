class String
   def scramble
       self.split(/\b/).inject(""){ |result, wordbit| result << (
         wordbit.match(/\w{4,}/)?
           (wordbit[0,1] << wordbit[1..-2].split(//).sort_by{ rand }.join("") << wordbit[-1,1]) :
           wordbit ) }
   end

   def scramble!
       self.replace self.scramble
   end
end
