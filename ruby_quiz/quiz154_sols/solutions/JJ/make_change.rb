def make_change_aux(amount, coins)
  return [[]] if amount == 0
  return [] if coins.empty? or amount < 0
  return make_change_aux(amount - coins[0], coins).collect {
           |n| n << coins[0]
         } + make_change_aux(amount, coins[1 .. -1])
end

def make_change(amount, coins = [25, 10, 5, 1])
  return make_change_aux(amount, coins).sort {
    |a, b| a.size <=> b.size
  }.first
end
