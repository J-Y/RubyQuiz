class Irr

 attr_accessor :data, :irr

 def initialize(data)
   @data = data
   @irr = 0
   irr_calculus
 end

 def npv_calculus(rate)
   npv = 0
   @data.each do |c|
     t = @data.index(c)
     npv = npv + c / (1 + rate)**t
   end
   npv
 end

 def irr_calculus
   r1 = 0.0
   r2 = 1.0
   npv1 = npv_calculus(r1)
   npv2 = npv_calculus(r2)

   # calcule initial interval
   while npv1*npv2 > 0
     r1 = r1 + 1
     r2 = r2 + 1
     npv1 = npv_calculus(r1)
     npv2 = npv_calculus(r2)
   end

   # halfing interval to achieve precission
   value = 1
   while value > (1.0/10**4)
     r3 = (r1+r2)/2
     npv3 = npv_calculus(r3)
     if npv1*npv3 < 0
       r2 = r3
       npv2 = npv3
     else
       r1 = r3
       npv1 = npv3
     end
     value = (r1-r2).abs
   end

   @irr = (r1*10000).round/10000.0
 end

end


data = [-100, 30, 35, 40, 45]
i = Irr.new(data)
puts i.irr
