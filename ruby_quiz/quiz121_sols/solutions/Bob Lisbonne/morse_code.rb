#!/usr/bin/env ruby -w
CW = {'.-'=>'A','-...'=>'B','-.-.'=>'C','-..'=>'D','.'=>'E','..-.'=>'F','--.'=>'G','....'=>'H','..'=>'I','.---'=>'J','-.-'=>'K','.-..'=>'L','--'=>'M','-.'=>'N','---'=>'O','.--.'=>'P','--.-'=>'Q','.-.'=>'R','...'=>'S','-'=>'T','..-'=>'U','...-'=>'V','.--'=>'W','-..-'=>'X','-.--'=>'Y','--..'=>'Z'}
def morse(dotsanddashes,letters)
	if dotsanddashes.empty? then
		puts letters
	else
		CW.keys.each do |try|
			if /^#{Regexp.escape(try)}/.match(dotsanddashes) then
				morse(dotsanddashes[$&.size,dotsanddashes.size],letters+ CW[$&])
			end
		end
	end
end #morse
morse(STDIN.read.chomp,'')
