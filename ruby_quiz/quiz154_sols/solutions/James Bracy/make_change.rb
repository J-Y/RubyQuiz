def make_change(amount, coins=[25,10,5,1], change={})
  coins.sort!
  puts change
  return change if coins.empty?

  if change.empty?
    change[coins.first] = amount / coins.first
    amount -= coins.first * change[coins.first]
  else
    change.each_pair do |k, count|
      change_count = count_change(change)
      if (amount+change_count) % coins.first == 0
        change[coins.first] = (amount+change_count) / coins.first
        change[k] = (change_count + amount - change[coins.first]*coins.first) / k
        amount -= change[coins.first] - change[k]
      else
        change[coins.first] = 0
      end
    end
  end

  make_change(amount, coins-change.keys, change)
end

def count_change(change={})
  total = 0
  change.each_pair do |coin, count|
    total += coin * count
  end
  total
end
