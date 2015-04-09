terms = []
ARGV[0].split(/\s/).each do |t|
  terms <<
  if %w(+ - / *).include?(t)
    "(#{terms.slice!(-2)} #{t} #{terms.slice!(-1)})"
  else
    t
  end
end
puts terms[0]
