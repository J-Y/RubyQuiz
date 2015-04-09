class Array
 #Try to get a unique response
 def any
   @anylist = [] if !@anylist
   response = nil
   (self.length*3).times do
     response = self[rand(length)]
     break if !(@anylist.include? response)
   end
   @anylist << response
   response
 end
end
