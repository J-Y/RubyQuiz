dice, n = ARGV.grep(/\d+/)
verbose = true if ARGV.include?("-v")
sample = true if ARGV.include?("-s")

max=("5"*dice.to_i).to_i(6)
n=n.to_i
resultat= (0..max).inject(0) do |sum,i|
  output = verbose || (sample && i % 50_000 == 0)
  print i+1,"\t",("%#{dice}s" % i.to_s(6)).split(//).map{|e| e.to_i+1}.inspect if output
  if i.to_s(6).scan(/4/).size > n-1
    puts "<=" if output
    sum+1
  else
    puts "" if output
    sum
  end
end

puts "Number of desirable outcomes is #{resultat}"
puts "Number of possible outcomes is #{max+1}"
puts Float(resultat) / Float(max+1)
