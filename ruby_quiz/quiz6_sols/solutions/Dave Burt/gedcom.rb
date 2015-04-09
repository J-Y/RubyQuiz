# GEDCOM to XML converter
# Response to Ruby Quiz #6
# Takes a GEDCOM file on STDIN and produces corresponding XML on STDOUT
# Author: Dave Burt <dave & burt.id.au>
# Created: 6 Nov 2004
# Last Updated: 6 Nov 2004

doc = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<gedcom>"

open_tags = ["gedcom"]

prev_level = root_level = nil

ARGF.each_line do |line|

	next if /^\s*$/ === line

	line = line.chomp.split(/\s+/, 3)
	
	level = line.shift.to_i
	
	if prev_level.nil?
		prev_level = root_level = level-1  # not assuming base level is 0
	end
	
	(level..prev_level).to_a.reverse.each do |i|
		doc << "\t" * (i - root_level) if doc[-1] == ?\n
		doc << "</#{open_tags.pop}>\n"
	end
	
	if line[0][0] == ?@
		xref_id, tag = line
		xref_id.gsub!(/^@(.*)@$/, '\1')
		id_attr = ' id="' + xref_id + '"'
		value = ''
	else
		tag, value = line
		id_attr = ''
		value ||= ''
		if /^@(\w+)@$/ === value
			value = "<xref>#{$1}</xref>"
		else
			value.gsub!(/&/, '&amp;')
			value.gsub!(/</, '&lt;')
			value.gsub!(/>/, '&gt;')
		end
	end
	
	if tag == 'CONC' || tag == 'CONT'
		doc << (tag == 'CONT' ? "\n" : " ")
		doc << value
		level -= 1
	else
		doc << "\n" if level > prev_level
		tag.downcase!
		doc << "\t" * (level - root_level) + "<#{tag}#{id_attr}>#{value}"
		open_tags.push tag
	end
	
	prev_level = level

end

while tag = open_tags.pop
	doc << "\t" * (open_tags.length) + "</#{tag}>\n"
end

puts doc