# Helpers
class Integer
   def even?
      (self % 2).zero?
   end
end

class Symbol
   def <=> other
      self.to_s <=> other.to_s
   end
end

# Constraint Solver class
class Problem
   def initialize(&block)
      @domain = {}
      @consts = Hash.new { [] }
      instance_eval(&block)
   end

   def variable(var, domain)
      raise ArgumentError, "Cannot specify variable #{var} more than once." if @domain.has_key?(var)
      @domain[var] = domain.to_a
   end

   def constrain(*vars, &foo)
      raise ArgumentError, 'Constraint requires at least one variable.' if vars.size.zero?
      vars.each do |var|
         raise ArgumentError, "Unknown variable: #{var}" unless @domain.has_key?(var)
      end
      @consts[vars] = @consts[vars] << foo
   end

   def solve
      # Separate constraint keys into unary and non-unary.
      unary, multi = @consts.keys.partition{ |vars| vars.size == 1 }

      # Process unary constraints first to narrow variable domains.
      unary.each do |vars|
         a = vars.first
         @consts[vars].each do |foo|
            @domain[a] = @domain[a].select { |d| foo.call(d) }
         end
      end

      # Build fully-expanded domain (i.e. across all variables).
      full = @domain.keys.map do |var|
         @domain[var].map do |val|
            { var => val }
         end
      end.inject do |m, n|
         m.map do |a|
            n.map do |b|
               a.merge(b)
            end
         end.flatten
      end

      # Process non-unary constraints on full domain.
      full.select do |d|
         multi.all? do |vars|
            @consts[vars].all? do |foo|
               foo.call( vars.map { |v| d[v] } )
            end
         end
      end
   end
end


# A simple example
problem = Problem.new do
   variable(:a, 0..10)
   variable(:b, 0..10)
   variable(:c, 0..10)

   constrain(:a) { |a| a.even? }
   constrain(:a, :b) { |a, b| b == 2 * a }
   constrain(:b, :c) { |b, c| c == b - 3 }
end

puts "Simple example solutions:"
problem.solve.each { |sol| p sol }

# Calculate some primes... The constraint problem actually finds
# the non-primes, which we remove from our range afterward to get
# the primes.
problem = Problem.new do
   variable(:a, 2..25)
   variable(:b, 2..25)
   variable(:c, 2..50)

   constrain(:a, :b) { |a, b| a <= b }
   constrain(:a, :b, :c) { |a, b, c| a * b == c }
end

puts "The primes up to 50:"
puts ((2..50).to_a - problem.solve.map { |s| s[:c] }).join(", ")
puts
