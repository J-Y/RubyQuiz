elegance = nil

#########################

to100 = Hash.new()

@setlength=9#set, starting from 1 to use

@maxops=@setlength-1#the maximum number of operators (including space)
in any equation

@operator = ["", "+", "-"]

@oplength = @operator.length

keylength = @oplength.power!(@maxops)



def bogoGen()

 little=Array.new(@setlength+@maxops) do

   |i|

   if i.modulo(2)==0 then

     i=i/2

     i+=1

   else

     i=@operator[rand(@oplength)]

   end

 end

 return(little.join)

end



writingHamlet = Time.now()



while to100.keys.length<keylength

 elegance = bogoGen()

 to100.store(elegance,eval(elegance))

 #puts "Found #{to100.keys.length} formulas" if to100.keys.length%100==0

end



millionMonkeys = Time.now()



to100.sort.each do

 |answer|

 fortytwo=answer[1]==100?'*':' '

 #display the answer!

 puts "#{fortytwo} #{answer[0]}=#{answer[1]} #{fortytwo}"

end



willFinish = Time.now()

#puts "Total calculation time: #{millionMonkeys - writingHamlet} seconds"

#puts "Total run time:         #{willFinish - writingHamlet} seconds"
