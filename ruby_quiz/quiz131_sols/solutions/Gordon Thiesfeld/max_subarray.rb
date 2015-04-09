class Array

  def sum
    inject{ |s,v| s + v }
  end

  def subarrays
    size.times{ |f| 1.upto(size - f){ |l| yield self[f,l] } }
  end

  def max_sum
    results = Hash.new{|h,k| h[k] = [] }
    subarrays{ |a| results[a.sum] << a }
    results.max.last.min
  end

end

p ARGV.map{ |i| i.to_i }.max_sum if __FILE__ == $PROGRAM_NAME
