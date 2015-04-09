#!/usr/bin/ruby
terms = []
ARGV[0].split(/\s/).each { |t| terms << (%w(+ - / *).include?(t) ?
"(#{terms.slice!(-2)} #{t} #{terms.slice!(-1)})" : t) }
puts terms[0]
