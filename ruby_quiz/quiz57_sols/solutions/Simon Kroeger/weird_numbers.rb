require 'set'

class Fixnum
  def weird?
    divisors = (1..1+self/2).select{|i| (self % i).zero?}
    return false if divisors.inject{|s, x| s + x} <= self
    !divisors.inject([0].to_set) do |sums, d| 
      sums.merge(sums.map{|s| s + d})
    end.include?(self)
  end
end

$stdout.sync = true
1.upto((ARGV.shift || 1000).to_i){|i| puts i if i.weird?}
