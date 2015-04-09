#!/usr/local/bin/ruby -w

class Array
  def without( other )
    result = dup
    other.each do |value|
      i = result.index(value) or next
      result.delete_at(i)
    end
    result
  end
  
  def sum
    inject { |sum, value| sum + value }
  end
end

def find_shares( target, treasures )
  shares = target.zero? ? [[target, Array.new, Array.new]] :
                          [[target, treasures.dup, Array.new]]
  
  until shares.empty?
    goal, pool, share = shares.pop
    first             = pool.shift
    
    shares << [goal, pool.dup, share.dup] unless pool.empty?
    if goal == first
      yield share + [first]
    elsif goal > first and not pool.empty?
      shares << [goal - first, pool.dup, share + [first]]
    end
  end
end

def divide_loot( target, treasures )
  total = treasures.sum
  
  return [treasures] if total == target

  unless (total % target).nonzero?
    loot = [[treasures.dup, Array.new]]
    
    until loot.empty?
      rest, divided = loot.pop

      find_shares(target, rest) do |share|
        new_rest  = rest.without(share)
        new_total = new_rest.sum
        
        if new_total == target
          return divided + [share, new_rest]
        elsif (new_total % target).zero?
          loot << [new_rest, divided.dup << share]
        end
      end
    end
  end

  nil
end

unless ARGV.size >= 2
  puts "Usage:  #{File.basename($PROGRAM_NAME)} ADVENTURERS TREASURES"
  exit
end
adventurers, *treasures = ARGV.map { |n| n.to_i }
target                  = treasures.sum / adventurers

if loot = divide_loot(target, treasures)
  loot.each_with_index do |share, index|
    puts "#{index + 1}: #{share.join(' ')}"
  end
else
  puts "It is not possible to fairly split this treasure #{adventurers} ways."
end
