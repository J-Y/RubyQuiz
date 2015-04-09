def make_change_aux(amount, coins)
  coin = coins.first
  if 1 == coins.size
    return 0 == amount % coin ? [coin] * (amount / coin) : nil
  end
  change = nil
  (amount/coin).downto([ amount/coin - coins[1], 0 ].max) do |n|
    a = make_change_aux(amount - n * coin,
                        coins.slice(1, coins.size-1))
    if a and (change.nil? or a.size + n < change.size )
        change =  ([ coin ] * n).concat(a)
    end
  end
  change
end

def make_change(amount, a = [25,10,5,1] )
  coins = a.uniq.sort.reverse
  coins.each do |c|
    raise "Not a positive integer value: #{c}" if c < 1 or c != c.to_i
  end
  if coins.empty?
    return 0 == amount ? [] : nil
  end
  make_change_aux(amount, coins)
end
