#!ruby

if ARGV.empty?
  puts "use: #$0 base min max <word files>"
  exit 0
end

base = ARGV.shift.to_i
min  = ARGV.shift.to_i
max  = ARGV.shift.to_i

raise "Low base" unless base > 10
raise "min max error" unless max >= min && min > 0

filter = Regexp.new "^[a-#{(?a + base - 11).chr}]{#{min},#{max}}$",
  Regexp::IGNORECASE

ARGF.each do |line|
  puts line if filter === line
end
