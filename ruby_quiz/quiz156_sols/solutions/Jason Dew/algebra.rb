module Algebra

 class MaximumIterationsReached < Exception
 end

 class NewtonsMethod

   def self.calculate(function, x)
     x - function.evaluated_at(x) / function.derivative_at(x)
   end

 end

 class NewtonsDifferenceQuotient

   def self.calculate(function, x, delta=0.1)
     (function.evaluated_at(x + delta) - function.evaluated_at(x) ).to_f / delta
   end

 end

 class Function


attr_accessor :differentiation_method, :root_method, :maximum_iterations, :tolerance

   def initialize(differentiation_method=NewtonsDifferenceQuotient, root_method=NewtonsMethod, &block)
     @definition = block
     @differentiation_method, @root_method = differentiation_method, root_method
     @maximum_iterations = 1000
     @tolerance = 0.0001
   end

   def evaluated_at(x)
     @definition.call(x)
   end

   def derivative_at(x)
     differentiation_method.calculate(self, x)
   end

   def zero(initial_value=0)
     recursive_zero(initial_value, 1)
   end

   private

   def recursive_zero(guess, iteration)
     raise MaximumIterationsReached if iteration >= @maximum_iterations

     better_guess = @root_method.calculate(self, guess)

     if (better_guess - guess).abs <= @tolerance
       better_guess
     else
       recursive_zero(better_guess, iteration + 1)
     end
   end

 end

end
