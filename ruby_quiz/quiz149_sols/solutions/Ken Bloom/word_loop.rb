def loopword word
 matchinfo=
   word.match(/(.*?)(.)(.(?:..)+?)\2(.*)/i)
 if matchinfo
   _,before,letter,looplets,after=matchinfo.to_a
   pad=" "*before.size
   after.reverse.split(//).each{|l| puts pad+l}
   looplets=looplets.split(//)
   puts before+letter+looplets.shift
   until looplets.empty?
     puts pad+looplets.pop+looplets.shift
   end
 else
   puts "No loop."
 end
end

loopword "Mississippi"
puts
loopword "Markham"
puts
loopword "yummy"
puts
loopword "Dana"
puts
loopword "Organization"
