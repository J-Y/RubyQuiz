class Array

  # solution 1
  def max_subs
    max_found, max_instances = 0, [[]]  # the empty sub array will 
always return 0 sum
    self.left_subs.each do |l_sub|
      next if l_sub.last.nil? || l_sub.last < 0   # if
      l_sub.right_subs.each do |sub|
        next if sub.first.nil? || sub.first < 0
        if (sub_sum = sub.sum) > max_found
          max_found, max_instances = sub_sum, [sub]
        elsif sub_sum == max_found
          max_instances << sub
        end
      end
    end
    return max_instances
  end

  # i hypothesise that each max sub array is actually;
  # a max left sub of a max right sub, and the other way round
  # but i dont have time to prove it

  # solutions 2 and 3
  def max_left_of_right
      max_right_subs.inject([]){|rtn, max_r| rtn + max_r.max_left_subs}
  end

  def max_right_of_left
      max_left_subs.inject([]){|rtn, max_l| rtn + max_l.max_right_subs}
  end


  # sub methods

  def left_subs
    if (l_sub = self.dup) && l_sub.pop
      return (l_sub.left_subs << self.dup)
    else
      return [self]
  end
  end

  def right_subs
    if (r_sub = self.dup) && r_sub.shift
      return (r_sub.right_subs << self.dup)
    else
      return [self]
  end
  end

  def sum
    self.inject(0){|sum, element| sum+element}
  end

  def max_left_subs
    max_of_subs(:left_subs)
  end

  def max_right_subs
    max_of_subs(:right_subs)
  end

  def max_of_subs(method)
    max_found, max_instances = 0, [[]] # we expect to have an empty sub
    self.send(method).each do |sub|
      if (sub_sum = sub.sum) > max_found
        max_found, max_instances = sub_sum, [sub]
      elsif sub_sum == max_found
        max_instances << sub
      end
    end
    return max_instances
  end
end
