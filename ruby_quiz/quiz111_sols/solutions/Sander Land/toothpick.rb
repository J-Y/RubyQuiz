class Fixnum
  def divisors
    @d ||= (2..self/2).select{|i| self % i == 0 }
  end
end

best_mul = Hash.new{|h,k|
  pos_mul = k.divisors.map{|d| h[d] + 'x ' + h[k/d] }
  h[k] = (pos_mul << '|'*k).sort_by{|tp|tp.length}.first
}

best_plus = Hash.new{|h,k|
  pos_plus = (k/2...k).map{|p| best_mul[p] + '+ ' + h[k-p] }
  h[k] = (pos_plus << best_mul[k]).sort_by{|tp|tp.length}.first
}.merge(1=>'|')

puts best_plus[ARGV[0].to_i].gsub(' ','').sub(/^$/,'Hug a Tree')