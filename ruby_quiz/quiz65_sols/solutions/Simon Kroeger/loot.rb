require 'set'

def choose_bags nr, bags, choice = Set[]
  return [] if choice.size == nr
  bags.each_with_index do |b, i|
    c = (choice & b).empty? && choose_bags(nr, bags, choice | b)
    return [i] + c if c
  end && nil
end

def split_loot  nr, *treasures
  each = (sum = treasures.sort!.reverse!.inject{|s, t| s + t}) / nr
  return nil if (sum % nr).nonzero?

  piles = Hash.new([]).merge!({0 => [[]]})
  treasures.each_with_index do |t, i|
    piles.dup.each do |k, v|
      if k + t <= each && k + sum >= each
        v.each{|a| piles[k + t] += [a + [i]]}
      end
    end
    sum -= t
  end
  return nil if piles[each].empty?
  return nil if !bags = choose_bags(treasures.size, piles[each])

  piles[each].values_at(*bags).map{|b| b.map{|t| treasures[t]}}
end

loot = split_loot(*ARGV.map{|p| p.to_i})
puts(loot ? loot.map{|a| a.join(' ')} : 'impossible!')
