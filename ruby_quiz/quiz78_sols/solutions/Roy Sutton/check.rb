desc = ARGV[0] || $stdin.gets.chomp
exit 1 if ((desc.scan(/[\[\]{}()]/).length % 2) == 1)
puts desc
