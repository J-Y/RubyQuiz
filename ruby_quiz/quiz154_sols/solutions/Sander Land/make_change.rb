def make_change(amount, coins = [25, 10, 5, 1])
 r = Hash.new{|h,k|
   h[k] = k<0 ? [1/0.0,[]] : coins.map{|c| l=h[k-c]; [l[0]+1,l[1]+[c]] }.min
 }.merge(0=>[0,[]])[amount]
 r[1] if r[0].to_f.finite?
end
