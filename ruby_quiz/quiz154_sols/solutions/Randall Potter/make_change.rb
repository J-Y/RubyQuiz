# rjspotter@gmail.com
# ruby quiz #154

def make_change(amount, coins = [25, 10, 5, 1])
  CoinChanger.make_change(amount, coins)
end

class CoinChanger
  
  class << self
    
    def make_change(amount, coins = [25, 10, 5, 1])
      coins = coins.sort.reverse
      change_options(amount,coins.clone).lightest.to_a(coins)
    end
    
  private
    
    # make change prefering the largest coins available
    def make_largest_change(amount, coins)
      orig_amount, change = amount, []
      coins.size.times {|index| change[index], amount = amount / coins[index], amount % coins[index] }
      amount > 0 ? make_largest_change(orig_amount + 1, coins) : change #  err in favor of larger amount returned
    end
    
    # make change prefering the smaller coins
    def alternate_options(amount, coins)
      inner_options, high, head, tail = [], amount / coins[0], coins[0], coins[1..-1]
      high.times {|n| inner_options << make_largest_change((amount - ((high - n) * head)), tail).unshift(high - n)}
      inner_options
    end
    
    # create permutations by shifiting off the head of the array until empty
    def change_options(amount,coins)
      ref_coins, options = coins.clone, alternate_options(amount, coins)
      until coins.empty?
        options << make_largest_change(amount, coins)
        coins.shift
      end
      # filter out inaccurate options if an accurate option exists. favor accuracy over efficiency
      accurate = options.uniq.map{|x| x if x.to_a(ref_coins).weight == amount}.compact
      accurate.empty? ? options : accurate
    end
    
  end
  
end

class Array
  
  def to_a(map_arr)
    new_form, mapping = [], normalize_size_to(map_arr.size)
    map_arr.size.times do |x|
      mapping[x].times { new_form << map_arr[x] }
    end
    new_form
  end
  
  def weight
    inject {|mem, y| mem += y}
  end
  
  def lightest 
    inject {|mem, x| mem.weight < x.weight ? mem : x }
  end

private

  # 0-pad the front of an array to length
  def normalize_size_to(integer)
    until size >= integer
      unshift 0
    end
    self
  end
  
end
