# solution #1 - Simple one-liner

p File.read(ARGV[0]).split("\n").reject{|w| w !~ 
%r"^[a-#{(?a-11+ARGV[1].to_i).chr}]+$"}.sort_by{|w| [w.length,w]} if 
(?a...?z)===?a-11+ARGV[1].to_i
