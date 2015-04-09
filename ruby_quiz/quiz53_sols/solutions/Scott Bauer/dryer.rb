original = ARGF.read
tokens = original.scan(/.{5,}?\b/).uniq.sort_by { |t| t.size }.reverse

tokens.size.times do |index|
	original.gsub!(Regexp.new(Regexp.escape(tokens[index])), ":#{index}-")
end

$stdout << <<"RONCO_REHYDRATOR"

original = <<"DRIED_THINGS"
#{original}
DRIED_THINGS

index = -1

Marshal.load(
<<"YUMMY_SERIAL"
#{Marshal.dump(tokens)}
YUMMY_SERIAL
).each do |token|
	original.gsub!(Regexp.new(":\#\{index += 1\}-"), token)
end

$stdout << original

RONCO_REHYDRATOR

