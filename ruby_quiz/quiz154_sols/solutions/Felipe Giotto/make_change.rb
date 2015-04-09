#!/usr/bin/ruby

def make_change(amount, coins = [25, 10, 5, 1])
  find_all_possible_changes(amount, coins).sort_by{|item| item.length}.first
end

def find_all_possible_changes(amount, coins)
  possibilities = []
  unless coins.empty?
    first_coin = coins.shift
    (amount / first_coin).downto 0 do |first_coin_count|
      try = Array.new(first_coin_count){first_coin}
      possibilities += (try.sum == amount) ? [try] : find_all_possible_changes(amount - (try.sum || 0), coins.dup).collect{|item| try + item}
    end
  end
  possibilities
end




#Refactoring method
class Array
  def sum; inject{|total, item| total + item}; end
end

#Section based on Alexander Stedile's submission: http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/288856
if __FILE__ == $0
  if ARGV[1]
    coins = ARGV[1].split(",").collect{ |coin| coin.to_i }
    puts make_change(ARGV[0].to_i, coins).inspect
  else
    puts make_change(ARGV[0].to_i, coins).inspect
  end
end
