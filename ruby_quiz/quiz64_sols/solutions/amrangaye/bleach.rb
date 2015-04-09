$tie="\t"*8

def whiten(laundry)
  #Change laundry to binary 1s and 0s...
  #then change those to tab and space characters. Finally add newlines after every 9th character
  result = laundry.unpack('b*').to_s.tr('01'," \t").gsub(/(.{9})/,"\\1\n")
  return $tie + result        #Add a tie to the washed shirt, and return it
end

def brighten(laundry)
  #Does the opposite of whiten
  laundry.sub!(/\t{8}/,'')    #Remove tie
  laundry.tr!("\n",'')    #Remove newlines
  laundry.tr(" \t",'01').to_a.pack('b*') #Change spaces and tabs to 0s and 1s, then repack them as binary
end

def dirty?(laundry)           #Laundry is dirty only if it contains non-space characters
  laundry =~ /\S/
end

def proper?(laundry)               #shirt is proper if it contains a tie
  laundry =~ /^#$tie/
end

shirt = IO.readlines($0).to_s          #Read in current program
shirt.sub!("require 'Bleach'",'')      #Remove require line

if(not dirty?(shirt) and proper?(shirt))
  eval brighten(shirt)
else
  file = File.new($0,"w")
  file.puts("require 'Bleach'")
  file.puts(whiten(shirt))
  file.close
end
