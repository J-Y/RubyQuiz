["()", "{}", "[]"].each { |symbol_pair| exit(1) if 0 != ARGV[0].count(symbol_pair) % 2 }
puts ARGV[0]
