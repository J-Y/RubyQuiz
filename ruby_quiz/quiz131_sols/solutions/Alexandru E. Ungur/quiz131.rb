class Array
  def sum() inject{|s,v|s+=v} end

  def max_sub_array
    max = { :sum => 0, :arr => [] }
    max_max = select{|x| x>0}.sum
    0.upto(size-2) do |i|
      next if self[i] < 0
      max_max -= self[i]
      break if max[:sum] > max_max
      i.upto(size-1) do |j|
        next if self[j] < 0
        if (tmp_sum = (tmp_arr = self[i..j]).sum) > max[:sum]
          max[:sum] = tmp_sum
          max[:arr] = tmp_arr
        end
      end
    end
    max
  end
end

if $0 == __FILE__
  ARRR = Array.new(100) { rand(200) - 100 }
  p ARRR.max_sub_array
end
