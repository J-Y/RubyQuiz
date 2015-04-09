input = ARGV.first

size = input.length
size -= 1 if size % 2 == 0

a = nil

in2 = input.downcase
while !a && size > 2 do
	a =  in2.index(/(.).{#{size}}(\1)/)
	size -= 2 if !a
end

if a then
	b = a + size + 1
	(input.length-1).downto(b+1) do |i|
		puts input[i,1].rjust(a+1)
	end
	puts input[0,a+2]
	space = a
	a += 2
	b -= 1
	while a < b do
		puts "#{"".rjust(space)}#{input[b,1]}#{input[a,1]}"
		a += 1
		b -= 1
	end
else
	puts "No Loop."
end
