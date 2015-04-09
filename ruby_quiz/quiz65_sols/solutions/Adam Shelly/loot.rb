class Integer
  def odd?
      self % 2 != 0
  end
end

def splitter n, loot
  splits=[]
  pile1,pile2=loot.dup.sort.reverse,[]
  total = loot.sum
  share = total/n
  num_odd = loot.inject(0){|s,g| g.odd? ? s+1 : s}

  # lots of ways to fail early:
  # doesn't divide evenly; not enough items; one item bigger than share size;
  # the number of items worth more than 1/2 share must be < number of shares
  # if the share size is even, there must be an even number of items with odd values
  # if the share size is odd, there must be an even number plus one for every share

  return nil if total%n != 0 || loot.size < n || loot.max > share
  return nil if loot.find_all{|g| g>share/2}.size > n
  num_odd-=n if share.odd?
  return nil if num_odd < 0 || num_odd.odd?

  #pile1 holds all the items we haven't tried to make a share with.
  #take a candidate from the pile.
  #if you can't make a share using that one, it is impossible to divide the loot.
  #othewise, keep trying to make shares.
  #if you get stuck, move the candidate to pile2, and start again.
  #if pile1 becomes empty, give up

  until pile1.empty?
    candidate = pile1.shift
    remaining = (pile1+pile2)
    splits[0] = remaining.find_subset_with_sum(share - candidate)
    break if !splits[0]
    splits[0].unshift candidate
    (1...n).each do |i|
        break if nil == (splits[i] = remaining.find_subset_with_sum(share))
        remaining.subtract(splits[i])
      end
      return splits if splits[n-1]
      pile2 << splits[0].shift
  end
  nil
end
