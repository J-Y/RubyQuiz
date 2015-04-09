require 'dictionary'
dicts = Hash.new
File.open("WORD.LST") do |file|
	file.each_line do |line|
		line.chomp!.downcase!
		(dicts[line.length] ||= []) << line
	end
end

dicts.each do |len,dict|
	dict.sort!
	File.open("dict#{0 if len<10}#{len}.txt", "w") do |file|
		file.write(dict.join("\n"))
	end
end

dicts.each do |len, dict|
	if len<50 then
		puts "Making dictionary graph for #{len} letter words"
		currdict = Dictionary.new(dict)
		File.open("dict#{0 if len<10}#{len}.dump", "w") do |file|
			Marshal.dump(currdict, file)
		end
	end
end
