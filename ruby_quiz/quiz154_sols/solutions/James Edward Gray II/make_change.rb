#!/usr/bin/env ruby -wKU

def make_change(amount, coins = [25, 10, 5, 1])
  return [ ] if amount.zero?
  
  coins = coins.sort_by { |coin| -coin }
  
  prev_totals = {0 => [ ]}
  loop do
    cur_totals = { }
    
    prev_totals.each do |prev_total, prev_coins|
      coins.each do |coin|
        cur_total, cur_coins = prev_total + coin, prev_coins + [coin]
    
        return cur_coins.sort_by { |coin| -coin } if cur_total == amount
        cur_totals[cur_total] ||= cur_coins       if cur_total < amount
      end
    end
    
    return if cur_totals.empty?

    prev_totals = cur_totals
  end
end

if __FILE__ == $PROGRAM_NAME
  amount, *coins = ARGV.map { |n| Integer(n) }
  abort "Usage:  #{$PROGRAM_NAME} AMOUNT [COIN[ COIN]...]" unless amount
  
  p coins.empty? ? make_change(amount) : make_change(amount, coins)
end
