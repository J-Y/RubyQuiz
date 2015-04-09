#!/usr/bin/env ruby -wKU
# -*- ruby -*-

file = nil
state = :init
ARGF.each do |line|
 case state
 when :init
   next unless line =~ /^==> (.*) <==$/
   if File.exist?($1)
     backup = $1+'~'
     File.delete(backup) if File.exist?(backup)
     File.rename($1, backup)
   end
   file = File.open($1, 'w')
   state = :writing
 when :writing
   file.write line
   if line.chomp == '__END__'
     file.close
     state = :init
   end
 end
end
