def split_loot(cnt, gems, first_call = true)
  return [gems] if cnt == 1
  sum = gems.inject(0) { |s, n| s + n }
  share = sum / cnt
  if first_call
    # only do these checks once
    if sum % share != 0 || gems.max > share || gems.empty?
      raise "impossible"
    end
  end
  # search all subsets of the gems whose sum is share, for each try to
  # split the remaining loot into cnt - 1 parts
  choose_stack = [0]
  share_sum = gems.first
  last = gems.size - 1
  until choose_stack.empty?
    while share_sum < share && choose_stack.last < last
      choose_stack << choose_stack.last + 1
      share_sum += gems[choose_stack.last]
    end
    if share_sum == share
      # recursive call
      rest_gems = gems.values_at(*((0...gems.size).to_a - choose_stack))
      if (res = split_loot(cnt - 1, rest_gems, false) rescue nil)
        return (res << gems.values_at(*choose_stack))
      end
    end
    if choose_stack.last == last
      share_sum -= gems[last]
      choose_stack.pop
    end
    unless choose_stack.empty?
      share_sum -= gems[choose_stack.last]
      choose_stack << choose_stack.pop + 1
      share_sum += gems[choose_stack.last]
    end
  end
  raise "impossible"
end

if $0 == __FILE__
  begin
    if ARGV.size >= 2
      cnt, *gems = ARGV.map { |s| Integer(s) }
    else
      # generate a test
      cnt = ARGV.shift.to_i
      share_sum = rand(1000)
      gems = []
      cnt.times {
        rest = share_sum
        while rest > 0
          cur = rand(rest) + 1
          gems << cur
          rest -= cur
        end
      }
    end
    split_loot(cnt, gems.sort.reverse).each_with_index { |s, i|
      puts "#{i+1}: #{s.join(' ')}"
    }
  rescue => e
    puts e
  end
end
