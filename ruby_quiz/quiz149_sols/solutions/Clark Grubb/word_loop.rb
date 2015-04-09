mid_pattern = (1..((ARGV[0].length-2)/2)).collect do |i|
 ".{#{2*i+1},#{2*i+1}}"
end.join('|')
if ARGV[0].match(/(.)(#{mid_pattern})\1/i)
 pre,letter,mid,post = $`,$1,$2,$'
 pre_space = pre.gsub(/./,' ')
 post.split('').reverse.each { |c| puts "#{pre_space}#{c}" }
 puts "#{pre}#{letter}#{mid[0].chr}"
 ((mid.length - 1)/2).times do |i|
   puts "#{pre_space}#{mid[-i].chr}#{mid[i+1].chr}"
 end
else
 puts "No loop."
end