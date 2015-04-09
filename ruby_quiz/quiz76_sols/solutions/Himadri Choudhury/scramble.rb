print ARGF.read.gsub!(/\B[a-z]+\B/) {|x| x.split('').sort_by{rand}.join}
