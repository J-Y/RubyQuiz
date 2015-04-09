# Rubyquiz #52, Ducksay
# ascii animals talking using ascii comic balloons.
#
#
# I couldn't get commandline arguments working properly on my machine, so I skipped it.
# Instead, change the variable values to suit your needs.
#
# This solution does not automatically wordwrap the sayings. Do it manually.



#templates are text files with ascii character and "Å" for
#tail character, "Ä" for one eye and "ÄÄ" for two eyes.
#e.g. cow.txt, duck.txt and duck2.txt
template = "duck2.txt"
#edit saying as per your wishes
saying = "Fourscore and seven years ago our fathers brought\nforth on this continent a new nation,\nconceived in liberty and dedicated to the\nproposition that all men are created equal."
#edit eye-style, "eyes" is for templates with two eyes, "eye" for one-eyed templates
eyes = "oo"
eye = "o"
#tongue, two chars
tongue = "@ "

#"think" for think-cloud, atm, there's only think and the default ("say") as per cowsay.net
cloud_type = "say"

#If you want another style of cloud, add one here.
#Also, the clouds tail-style is decided here as well.
#Remember to escape special characters.
if cloud_type == "think" then
  cloud_oneline_left = "("
  cloud_oneline_right = ")"
  cloud_upper_left = "("
  cloud_upper_right = ")"
  cloud_middle_left = "("
  cloud_middle_right = ")"
  cloud_lower_left = "("
  cloud_lower_right = ")"
  tail = "o"
else
  cloud_oneline_left = "<"
  cloud_oneline_right = ">"
  cloud_upper_left = "/"
  cloud_upper_right = "\\"
  cloud_middle_left = "|"
  cloud_middle_right = "|"
  cloud_lower_left = "\\"
  cloud_lower_right = "/"
  tail = "\\"
end

#The ducksay application

#prints out as many spaces as the first argument (an integer),
#then puts the string, which defaults to ""
def output_spaces (intnumber, string="")
  intnumber.times { print " " }
  puts string
end
def output_chars (intnumber, string=" ")
  intnumber.times { print string }
  puts
end


#the balloon, and the saying
  print "   " #put start of the balloon at proper place
unless saying.include? ?\n then
  #single line saying
  output_chars(saying.length, "_")
  puts "  " + cloud_oneline_left + saying + cloud_oneline_right
  print "   " #put closing of balloon at proper place
  output_chars(saying.length, "-")
  puts
else
  #multiple line saying
  saying = saying.split("\n")
  longest_line = 0
  saying.each do |x|
    longest_line = x.length if (x.length > longest_line)
  end
  output_chars(longest_line, "_")
  #First line of the multi-line cloud
  current_line = saying.shift
  print_spaces = longest_line - current_line.length
  print "  " + cloud_upper_left + current_line 
  output_spaces(print_spaces, cloud_upper_right)  
  #The rest of the lines
  while not saying.empty?
    current_line = saying.shift
    print_spaces = longest_line - current_line.length    
    if saying.empty? then
    #When on the last line, "close" the cloud with cloud_lower_left and _right chars
      print "  " + cloud_lower_left + current_line
      output_spaces(print_spaces, cloud_lower_right)
    else
    #Put proper left and right chars for the cloud when in the "middle" of it
      print "  " + cloud_middle_left + current_line 
      output_spaces(print_spaces, cloud_middle_right)
    end  
  end
  print "   " # put the clouds closing at proper place
  output_chars(longest_line, "-")
end

#print out the template, aka, the ascii animal
#in the template files, "Å" substitutes the tail, "Ä" one eye, and "ÄÄ" two eyes
File.open(template) do |file|
  while line = file.gets
    #substitute the placeholder characters with the cloud tail and eye(s), then print it out
    line.gsub!("#tail#", tail)
    line.gsub!("#eyes#", eyes)
    line.gsub!("#eye#", eye)
    line.gsub!("#tongue#", tongue)
    puts line
    end
end
