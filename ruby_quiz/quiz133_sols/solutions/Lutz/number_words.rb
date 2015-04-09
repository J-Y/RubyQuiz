#!/usr/bin/env ruby

exit if ARGV.size < 1

base = ARGV[0].to_i
length = ARGV[1].to_i || 0

IO.foreach "/usr/share/dict/american-english" do |line|
  if (length > 0 and line.chomp.length == length) or length == 0
    i = line.to_i base
    puts "#{line.chomp} base #{base} = #{i}" if i > 0
  end
end
