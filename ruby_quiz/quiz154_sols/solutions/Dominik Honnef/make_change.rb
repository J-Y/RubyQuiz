def make_change(amount, coins = [25, 10, 5, 1])
  returns = []
  coins.sort! {|a,b| b<=>a}
  coins.size.times do |index|
    temp_amount = amount
    returns[index] = []
    coins[index..-1].each do |coin|
      returns[index] += [coin]*(temp_amount/coin)
      temp_amount %= coin
    end
  end
  returns.delete_if {|item| item.inject{|sum, i| sum+i} != amount }
  return (returns.sort {|a,b| a.size <=> b.size})[0]
end

puts (make_change(39)).inspect #United States
#=> [25, 10, 1, 1, 1, 1]
puts (make_change(14, [10, 7, 1])).inspect #Always give smallest amount of coins
#=> [7, 7]