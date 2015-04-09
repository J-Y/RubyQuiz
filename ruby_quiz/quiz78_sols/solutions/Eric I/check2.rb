description = ARGV[0].dup
while description.gsub!(/\(B\)|\[B\]|{B}|BB/, "B")
  #empty
end
exit(1) unless description == "B"
puts ARGV[0]
