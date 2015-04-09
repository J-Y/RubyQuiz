#!/usr/bin/env ruby

require "csv"

def clean( numbers )
	numbers.map! do |n|
		n.gsub!(",", "")
		if n.sub!(/K$/, "")
			n.to_i * 1000
		elsif n !~ /%/
			n.to_i
		else
			n
		end
	end
	
	numbers.each_with_index do |n, i|
		if n.to_s =~ /%/
			numbers[i] = ( (numbers[i - 2] - numbers[i - 1]) /
						   numbers[i - 1].to_f * 100 ).to_i
		end
	end
	
	numbers
end

def labels
	period = ""
	headers = [ ]
	while line = ARGF.gets
		headers << line
		headers.shift if headers.size > 4
		
		period = $1 if line =~ /General Sales Report\s+(.+?)\s*$/
	
		break if line =~ /^-[- ]+-$/
	end

	pattern = headers.pop.split(" ").map { |s| "a#{s.length}" }.join("x")

	types = { }
	headers.map! do |h|
		h.gsub!(/-+(([A-Z])[^-]+)-+/) do |m|
			types[$2] = $1
			$2 * m.length
		end
		
		h.unpack(pattern).map do |s|
			if s =~ /^([A-Z])\1+$/ and types.include?($1)
				types[$1]
			else
				s.strip
			end
		end
	end
	
	headers.transpose.map { |h| h.join(" ").lstrip } << period
end

puts CSV.generate_line(labels)

header = false
while line = ARGF.gets
	if header
		header = false if line =~ /^-[- ]+-$/
	else
		if line =~ /\f/
			header = true
			next
		end
		next if line =~ /--$/
		
		if line !~ /\S/
			puts CSV.generate_line([""])
		elsif line =~ /^(.+?totals)((?:\s+(?:-?[\d,]+K?|%+)){12})\s*$/i
			puts CSV.generate_line(["", $1.lstrip, *clean($2.split(" "))])
		elsif line =~ /^(\S+)\s+(.+?)((?:\s+(?:-?[\d,]+K?|%+)){12})\s*$/
			puts CSV.generate_line([$1, $2, *clean($3.split(" "))])
		else
			puts CSV.generate_line(["", line.strip])
		end
	end

	break if line =~ /^Report Totals/
end
