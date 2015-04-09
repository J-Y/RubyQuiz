print ARGF.read.gsub!(/\B[a-z]+\B/) {|x| x.unpack('c*').sort_by{rand}.pack('c*')}
