# solution #2 - Non-hackery substs, like Olaf

p File.read(ARGV[0]).split("\n").reject{|w| w !~ 
%r"^[a-#{(?a-11+ARGV[1].to_i).chr}|lO]+$"}.sort_by{|w| [w.length,w]} if 
(?a...?k)===?a-11+ARGV[1].to_i