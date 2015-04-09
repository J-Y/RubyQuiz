class Integer
  def weird?
    (d = divisors).pop   #remove self (which is always last)
    d.sum > self &&
      !d.quick_find_subset_with_sum(self) &&  #weed out most
      !d.find_subset_with_sum(self)           #confirm the rest
  end

  def divisors
    factors.all_combinations.uniq.inject([]){|result,combo|
      result << combo.product
    }.sort.uniq
  end

  def factors
    value, candidate = self, 3
    factors = [1]
    while value % 2 == 0
      factors << 2
      value /= 2
    end
    while candidate <= Math.sqrt(value)
      while value % candidate == 0
        factors << candidate
        value /= candidate
      end
      candidate += 2
    end
    factors << value if value != 1
    factors
  end
end


class Array
  def product
    inject(1){|p,v| p*v}
  end
  def sum
    inject(0){|s,v| s+v}
  end
  def all_combinations
    ComboIndexGenerator.new(self.size).inject([]) {|result, index_set|
      result << values_at(*index_set)
    }
  end

  #this was my first attempt, which was straightforward,
   # but slow as heck for large sets
  def slow_find_subset_with_sum n
    return nil if sum < n
    all_combinations.each {|set|
      return set if set.sum == n
    }
    nil
  end

  #this is my second attempt which is fast but misses some subsets.
  #but it is useful for quickly rejecting many non-weird numbers.
  def quick_find_subset_with_sum n
    a = self.sort.reverse
    sum,set = 0,[]
    a.each {|e|
      if (sum+e <= n)
        sum+=e
        set<<e
      end
      return set if sum == n
    }
    nil
  end

  #this one works pretty quickly...
  #it never tests subsets which are less than the sum,
  #and keeps track of sets it has already calculated
  def find_subset_with_sum n
    possibilities, seen  = [self],{}
    until possibilities.empty?
      candidate = possibilities.pop
      diff = candidate.sum - n
      return candidate if diff == 0
      break if diff < 0
      candidate.each_with_index{|e,i|
        break if e > diff
        new_cand = (candidate.dup)
        new_cand.delete_at(i)
        return new_cand if e == diff
        possibilities << new_cand if !seen[new_cand]
        seen[new_cand]=true
      }
    end
    nil
  end
end


#this class generates an all the possible combinations of n items
#it returns an array with the next combination every time you call #next
class ComboIndexGenerator
  include Enumerable
  def initialize nitems
    @n = nitems
    @max = 2**@n
    @val=0
  end
  def to_a
    return nil if @val==@max
    (0..@n).inject([]){|a,bit| a<<bit if @val[bit]==1; a}
  end
  def next
    @val+=1 if @val<@max
    to_a
  end
  def each &b
      yield to_a
    while (n=self.next)
      yield n
    end
  end
end


if $0 == __FILE__

 if ARGV.length < 1
   puts "Usage: #$0 <upper limit>"
   exit(1)
 end

 puts "Weird numbers up to and including #{ARGV[0]}:"
 70.upto(ARGV[0].to_i) do |i|
   puts i if i.weird?
 end
end
