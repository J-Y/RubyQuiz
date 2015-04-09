require 'dictionary'
if(ARGV.length != 2) then puts "Two words required"; exit(1) end
from = ARGV[0]
to = ARGV[1]
if(from.length != to.length) then puts "Word are different lengths";
exit(1) end
dict = nil
File.open("dict#{0 if from.length<10}#{from.length}.dump") do |file|
	dict = Marshal.load(file)
	chain = dict.chain(from, to)
	if(chain) then
		puts chain.join("\n")
	else
		puts "No link found"
	end
end
