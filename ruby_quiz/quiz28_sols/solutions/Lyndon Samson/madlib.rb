template="Our ((var1:a)) favorite ((var2:bb)) language ((var1)) is ((a
gemstone))."
vars={}

rep = template.gsub(/\(\((.*?)\)\)/) { |match|

  toks = match.split(":")
  if toks.length == 1
    varName = nil
    varPrompt=toks[0][2..(toks[0].length-3)]
  else
    varName=toks[0][2..(toks[0].length-1)]
    varPrompt=toks[1][0..(toks[1].length-3)]
  end

# Alternative but just a many lines
#  ndx = match.index(":")
#  if ndx == nil
#    varName   = nil
#    varPrompt = match[2..(match.length-3)]
#  else
#    varName   = match[2..(ndx-1)]
#    varPrompt = match[(ndx+1)..(match.length-3)]
#  end 

  if varName == nil && vars[varPrompt] != nil
    userInp=vars[varPrompt]
  else
    print "#{varPrompt} "
    userInp=gets.chomp
    vars[varName]=userInp
  end

  userInp
}

puts rep
