require 'lisp'

lisp = Object.new
lisp.extend(Lisp)
lisp.extend(Lisp::StandardFunctions)

require 'open-uri'
require 'fix_proxy.rb'

open("http://www.lisperati.com/code.html") { |f|
	input = f.readlines.join.gsub(/<[^>]*>/, "")
	#puts input
	lisp.lisp(input)
}

commands = [
	["(pickup whiskey-bottle)", "(YOU ARE NOW CARRYING THE WHISKEY-BOTTLE)"]
]
open("http://www.lisperati.com/cheat.html") { |f|
	f.each { |line|
		line.chomp!
		line.gsub!("<br>","")
		if /^>(.*)/ === line
			line = $1
			line.gsub!("Walk", "walk") #bug in input
			commands << [line, ""]
		else
			line.gsub!("WIZARDS", "WIZARD'S") #bug in input
			line.gsub!("ATTIC OF THE WIZARD'S", "ATTIC OF THE ABANDONED") #bug in input
			commands[-1][1] << line
		end
	}
}
commands.each do |c|
	puts c[0]
	result = lisp.lisp(c[0])
	result = result.to_lisp.upcase
	unless result == c[1]
		puts "Wrong!"
		p result
		p c[1]
		break
	end
end



