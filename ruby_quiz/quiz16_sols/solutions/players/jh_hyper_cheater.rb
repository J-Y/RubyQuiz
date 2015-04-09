class HyperCheater < Player
 def initialize(opponent)
   @opponent=opponent
   Object.const_get(opponent).send :define_method, :choose do
     :scissors
   end
 end
 def choose
   :rock
 end
 def result( you, them, win_lose_or_draw )
       Object.const_get(@opponent).send :define_method, :choose do
         :scissors
       end
       Object.const_get(self.class.to_s).send :define_method, :choose do # SelfRepair
         :rock
       end
 end
end
