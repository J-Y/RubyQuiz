num = ARGV[0].to_i
if num % 2 != 0 and num > 0
mid = ((num + 1) / 2) - 1
tot = []
num.times {tot.push(Array.new(num,"empty"))}

 (1..num**2).each do |x|
 tot.unshift(tot.pop)
 tot.each {|g| g.push(g.shift)}

   if tot[0][mid] != "empty"
   2.times {tot.push(tot.shift)}
   tot.each {|g| g.unshift(g.pop)}
   tot[0][mid] = x.to_s.rjust((num**2).to_s.length)
   end

   tot[0][mid] = x.to_s.rjust((num**2).to_s.length) if tot[0][mid] == "empty"
 end

tot.push(tot.shift)
tot.each {|x| p x.join(" ")}
end
