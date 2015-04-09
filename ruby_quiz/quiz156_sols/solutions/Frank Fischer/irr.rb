def evaluate( cost_flows, x, n = 0 )
   if n >= cost_flows.size
       0.0
   else
       cost_flows[n] + evaluate(cost_flows, x, n+1) / (1.0 + x)
   end
end

def irr( cost_flows, x = 0 )
   d_cost_flows = (0...cost_flows.size).map{|t| -t*cost_flows[t]}

   begin
       y = evaluate( cost_flows, x )
       yd = evaluate( d_cost_flows, x ) / (1.0+x)
       x -= y/yd
   end until y.abs < 1e-9

   return x
end
