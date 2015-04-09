class Array
 def score
   (s=inject(:+)) <= 11 && index(1) ? s+10 : s
 end
end

unless ARGV[0]
(1..10).each{|n| puts `ruby1.9 #{__FILE__} #{n}`}
exit
end

puts "upcard: #{upcard = ARGV[0].to_i}"
NDECKS = (ARGV[1]||2).to_i
CARDS = (((1..10).to_a+[10]*3)*4*NDECKS).tap{|c| c.delete_at c.index(upcard)}

score_count = [0]*27
cards = []
N=(ARGV[2]||1_000_000).to_i
N.times{
cards = CARDS.dup.shuffle if cards.size < 17
dealer = [upcard]
dealer << cards.pop while dealer.score < 17
score_count[dealer.score] += 1
}

puts %w[17 18 19 20 21 bust].join('     ')
puts (score_count[17..21] << score_count[22..-1].inject(:+)).map{|x|
'%-4.1f%%  ' % (100.0*x / N )}.join
