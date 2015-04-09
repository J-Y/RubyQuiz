class IncomeStream
 DEFAULT_TOLERANCE = 0.000_000_05

 def self.irr(*flows)
   self.new(flows).irr
 end

 def self.npv(discount_rate, *flows)
   self.new(flows).npv(discount_rate)
 end

 def self.dpv(amount, time)
   lambda {|rate| (-time) * amount * (1+rate)**(-time-1)}
 end

 def self.pv(amount, time)
   lambda {|rate| amount * (1+rate)**(-time)}
 end

 def initialize(flows)
   @flows = flows.to_a
   if (not @flows.empty?) and (@flows.first.kind_of? Numeric)
     @flows.each_index {|idx| @flows[idx]=[@flows[idx],idx]}
   end
   @pvs = @flows.map {|amount, time| IncomeStream.pv(amount, time)}
   @dpvs = @flows.map {|amount, time| IncomeStream.dpv(amount, time)}
 end

 def npv(rate)
   @pvs.inject(0) {|npv, item| npv+item.call(rate)}
 end

 def dnpv(rate)
   @dpvs.inject(0) {|dnpv, item| dnpv+item.call(rate)}
 end

 def irr(tolerance=DEFAULT_TOLERANCE)
   return nil if @flows.empty? or @flows.all? {|amount, time| amount = 0}
   rate = 0.0
   while (((n=npv(rate)).abs > tolerance) and rate.finite?)
     d = dnpv(rate)
     rate -= n/d
   end
   rate
 end
