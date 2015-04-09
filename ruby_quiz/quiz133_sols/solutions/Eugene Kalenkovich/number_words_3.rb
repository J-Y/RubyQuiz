# solution #3 - c001 hackerz

p File.read(ARGV[0]).split("\n").reject{|w| w !~ 
%r"^[a-#{(?a-11+ARGV[1].to_i).chr}|lo]+$"i}.map{|w| 
w.downcase.gsub('o','0').gsub('l','1')}.sort_by{|w| [w.length,w]} if 
(?a...?k)===?a-11+ARGV[1].to_i
