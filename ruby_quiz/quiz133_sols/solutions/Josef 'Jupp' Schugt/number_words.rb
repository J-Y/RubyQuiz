p = /^[#{"0123456789abcdefghijklmnopqrstuvwxyz"[0...ARGV[0].to_i]}]+$/i
puts File.open(ARGV[1]).readlines.reject!{|l| l !~ p}
