#!/usr/bin/env ruby -wKU
# -*- ruby -*-

Dir[ARGV[0] || '*.rb'].each do |f|
 lines = IO.readlines(f)
 lines.unshift "==> #{f} <==\n"
 lines << "__END__\n" unless lines.last.chomp == '__END__'
 lines << "\n"
 puts lines
end
