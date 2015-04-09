#!/usr/bin/env ruby19

require 'date'

module IRR
   module_function

   # Use Secant method to find the roots. In case, the upper and lower
   # limit diverge, reset the start values.
   #
   # This method may miss certain IRRs outside the [0.0..1.0]
   # intervall. In such a case use #irrer or set the optional :a
   # (lower limit) and :b (upper limit) arguments.
   #
   # Based on:
   # http://en.wikipedia.org/w/index.php?title=Secant_method
   def irr(values, args={})
       a  = a0 = args[:a] || 0.0
       b  = b0 = args[:b] || 1.0
       n  = args[:n] || 100
       e  = args[:e] || Float::EPSILON
       c0 = (a - b).abs
       ab = nil
       n.times do
           fa = npv(values, a)
           fb = npv(values, b)
           c  = (a - b) / (fa - fb) * fa;
           if c.nan?
               does_not_compute(values)
           elsif c.infinite?
               # break
               return c
           elsif c.abs < e
               return a
           end
           # Protect against bad start values.
           if c.abs > c0
               ab ||= guess_start_values(values, args.merge(:min => a0, :max => b0))
               if !ab.empty?
                   a, b, _ = ab.shift
                   c0 = (a - b).abs
                   next
               end
           end
           b  = a
           a  = a - c
           c0 = c.abs
       end
       does_not_compute(values)
   end

   # Guess appropriate start values, return all solutions as Array.
   def irrer(values, args={})
       guess_start_values(values, args).map do |a, b|
           irr(values, args.merge(:a => a, :b => b))
       end
   end

   # Calculate the NPV for a hypothetical IRR.
   # Values are either an array of cash flows or of pairs [cash,
   # date or days].
   def npv(values, irr)
       sum  = 0
       d0   = nil
       values.each_with_index do |(v, d), t|
           # I have no idea if this is the right way to deal with
           # irregular time series.
           if d
               if d0
                   t = (d - d0).to_f / 365.25
               else
                   d0 = d
               end
           end
           sum += v / (1 + irr) ** t
       end
       sum
   end

   def does_not_compute(values)
       raise RuntimeError, %{Does not compute: %s} % values.inspect
   end

   # Check whether computation will converge easily.
   def check_values(values)
       csgn = 0
       val, dat = values[-1]
       values.reverse.each do |v, d|
           csgn += 1 if val * v < 0
           val = v
       end
       return csgn == 1
   end

   # Try to find appropriate start values.
   def guess_start_values(values, args={})
       min   = args[:min]   || -1.0
       max   = args[:max]   ||  2.0
       delta = args[:delta] ||  (max - min).to_f / (args[:steps] || 100)
       vals  = []
       b, fb = nil
       # The NPV is undefined for IRR < -100% or so they say.
       min.step(max, delta) do |a|
           fa = npv(values, a)
           if fb and !fa.infinite? and !fb.infinite? and fa * fb < 0
               vals << [b, a]
           end
           b  = a
           fb = fa
       end
       return vals
   end

end


if __FILE__ == $0
   values = ARGV.map do |e|
       v, d = e.split(/,/)
       v = v.to_f
       d ? [v, Date.parse(d)] : v
   end
   puts "Default solution: #{IRR.irr(values) rescue puts $!.message}"
   begin
       IRR.irrer(values).zip(IRR.guess_start_values(values)) do |irr, (a, b)|
           puts '[%5.2f..%5.2f] %13.10f -> %13.10f' % [a, b, irr, IRR.npv(values, irr)]
       end
   rescue RuntimeError => e
       puts e.message
   end
   puts "Possibly incorrect IRR value(s)" unless IRR.check_values(values)
end
