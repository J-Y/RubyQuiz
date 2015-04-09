class Array
  def max_sub_array
    return [] if self.empty?
    self.max_sub_arrayr[0]
  end

  def max_sub_arrayr
    ary = self.clone
    sub_ary = Array.new.push(ary.shift)
    sum = sub_ary[0]
    max_sub_ary = sub_ary.dup
    max_sum = sum
    done = false
    ary.each_with_index do |n,i|
      if sum > 0
        if sum + n > 0
          sum += n
          sub_ary.push(n)
        else
          sub_ary, sum = ary.dup.slice(i..(ary.size-1)).max_sub_arrayr
          done = true
        end
      elsif sum <= n
        sub_ary, sum = ary.dup.slice(i..(ary.size-1)).max_sub_arrayr
        done = true
      end
      if sum > max_sum
        max_sum = sum
        max_sub_ary = sub_ary.dup
      end
      break if done
    end
    return max_sub_ary, max_sum
  end
end
