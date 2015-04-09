#!/usr/bin/env ruby
# cat file.txt | ./76.rb
while true
	s = gets;n = ""
	exit if s.nil?;s = s.gsub(/\n/," ")
	exit if s.gsub(/ /,"").empty?
	s.split.each do |w|
		x = w.split ""
		f = x.shift;l = x.pop
		f << x.shift if f == "\""
		l =  x.pop + l if l == "." or l == "!" or l == "?" or l == ","
		l =  x.pop + l if l == "\""
		x = f + (x.sort_by {rand}).to_s + l
		n << x << " "
	end
	puts n
end
