puts $<.read.split(/\W/).map{|x|x==""||nil 
?"":"#{x[0..0]}#{x[1...a=x.size-1].split(//).sort{rand}}#{x[a..a+1]} 
"}*""
