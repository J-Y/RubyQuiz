verbose = ARGV.delete("-v")
sample = ARGV.delete("-s")
dice, amt_of_fives = ARGV[0,2].map{|i| i.to_i }

num_outcomes = 6**dice
des_outcomes = 0
idx = 1
(0...num_outcomes).each{|oc|
  s = oc.to_s(6)
  hits = s.count("4")
  hit = hits >= amt_of_fives
  des_outcomes += 1 if hit
  if verbose or (sample and idx % 50000 == 1)
    # HA ha fhgh (justify, add one, reverse and
    # make into an array string to match kenneth's output)
    puts "#{idx} [#{s.rjust(dice,"0").tr!("012345","123456").reverse!.
                    split(//).join(",")}]#{hit ? " <==" : nil}"
  end
  idx += 1
}

puts
puts "Number of desirable outcomes is #{des_outcomes}"
puts "Number of possible outcomes is #{num_outcomes}"
puts
puts "Probability is #{des_outcomes.to_f / num_outcomes}"
