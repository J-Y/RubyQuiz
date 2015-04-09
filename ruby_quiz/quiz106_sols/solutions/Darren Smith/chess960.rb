# Chess960 minimalist version
# Author: Darren Smith
# Usage: ruby $0 [1..960] (omit for random position)

i=$*[0]||rand(960)+1
srand 1558
p=%w'K R N B B Q N R'
h={}
while h.size<i.to_i
	p=p.sort_by{rand}
	$_=p*'  '
	h[$_]=1if~/R.*K.*R/&&~/B(..)*B/
end
puts"Position ##{i}:",$_

