#!/usr/bin/ruby
# author: Yoan Blanc <yoan at dosimple.ch>
# revision: 20080118

text = STDIN.read

(text.length/2).downto 1 do |l|
	match = Regexp.new("(.{#{l}})\\1").match(text)
	if match
		puts text[match.offset(1)[0]..(match.offset(1)[1]-1)]
		break
	end
end