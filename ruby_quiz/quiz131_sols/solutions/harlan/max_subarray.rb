#!/usr/local/bin/ruby -w

# RubyQuiz #131 Submission  
# Maximum Sub-Array         
# O(n)                      
# by hrln                   

if __FILE__==$0:
  if ARGV.empty?
    puts %(usage:: $ruby max_sub_array.rb 1 -2 3 -4 5 -6 ...); Kernel.exit
  else
    arr = ARGV.map{|n| n.to_i}
    #arr = [-1, -2, 3, 5, 6, -2, -1, 4, 0, 0, 1]
  end

  max_b, max_e, max_s, tmp_b, tmp_e, tmp_s, neg_s = [0]*7

  arr.each_with_index do |el, i|
    if el <= 0
      tmp_e = i
      neg_s += el
    elsif el > 0
      if neg_s <= 0
        if el + neg_s > 0
          tmp_s += el + neg_s
          tmp_e, neg_s = i, 0
          max_b, max_e, max_s = tmp_s > max_s ? [tmp_b, tmp_e, tmp_s] : [max_b, max_e, max_s]
        else
          max_b, max_e, max_s = tmp_s > max_s ? [tmp_b, tmp_e, tmp_s] : [max_b, max_e, max_s]
          tmp_b, tmp_e, tmp_s, neg_s = [i, nil, 0, 0]
        end
      else
        tmp_s += el
        tmp_e = i
      end
    end
  end

  puts arr[max_b..max_e].inspect
end
