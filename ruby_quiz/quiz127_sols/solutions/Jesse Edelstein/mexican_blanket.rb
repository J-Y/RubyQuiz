def gradient(color_list)
old = [color_list[0]]
pattern = old*5
(1...color_list.length).each do |i|
  new = [color_list[i]]
  1.upto(5) { |j| pattern += new*j + old*(5-j) }
  old = new
end
return pattern
end

def divider(color)
[color.to_s]*5
end

def mexico
["28"]*4 + ["15"]*4 + ["88"]*4
end

# generate pattern
pattern = gradient(%w[16 22 28 34 40 46])
pattern += divider(0)   #divider
pattern += gradient(%w[21 20 19 18 17 16])
pattern += mexico
pattern += gradient(%w[196 197 198 199 200 201])
pattern += divider(0)
pattern += gradient(%w[226 220 214 208 202 196])

# width of the flag from CLI
flagwidth = ARGV[0] ? ARGV[0].to_i : 80

# translate to xterm (256-color) control codes, and then print
pattern.collect! {|i| "\033[48;5;#{i}m "}
while (pattern.length >= flagwidth) do
puts pattern[0...flagwidth].join + "\033[0m"
pattern.slice!(0)
end
