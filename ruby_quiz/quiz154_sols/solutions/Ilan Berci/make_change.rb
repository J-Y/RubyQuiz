#!/usr/bin/env ruby

def make_change(amount, coins = [25,10,5,1])
 coins.sort.reverse.map{|coin| f = amount/coin; amount %= coin; Array.new(f){coin} }.flatten
end

p make_change(ARGV[0].to_i, ARGV[1].split(',').map {|a| a.to_i})
