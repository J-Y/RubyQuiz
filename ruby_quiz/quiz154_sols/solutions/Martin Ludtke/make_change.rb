def make_change(amount, coins = [25, 10, 5, 1])
 change = { 0 => [] }
 until change.has_key?(amount)
   new_change = {}
   change.each do |amt, chg|
     coins.each { |c| new_change[amt + c] = [c] + chg unless
         amt + c > amount or change.has_key?(amt + c) }
   end
   return nil if new_change.empty?
   change.merge!(new_change)
 end
 change[amount].sort.reverse
end
