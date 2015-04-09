#!/usr/bin/env ruby

expr = ARGV[0] || abort('Please specify expression, such as "(5d5-4)d(16/d4)+3"')
expr = expr.dup  # unfreeze

class Object
  def method_missing(name, *args)
    # Intercept dieroll-method calls, like :_5d5, and compute
    # their value:
    if name.to_s =~ /^_(\d*)d(\d+)$/
      rolls = [1, $1.to_i].max
      nsides = $2.to_i
      (1..rolls).inject(0) {|sum,n| sum + (rand(nsides) + 1)}
    else
      raise NameError, [name, *args].inspect
    end
  end
end

class String
  def die_to_meth
    # Prepend underscore to die specs, like (5d5-4) -> (_5d5-4)
    # making them grist for our method_missing mill:
    self.gsub(/\b([0-9]*d[0-9]*)\b/, '_\1')
  end
end

expr.gsub!(/d%/,"d100")  # d% support
# inner->outer reduce
true while expr.gsub!(/\(([^()]*)\)/) {eval($1.die_to_meth)}
p eval(expr.die_to_meth)
