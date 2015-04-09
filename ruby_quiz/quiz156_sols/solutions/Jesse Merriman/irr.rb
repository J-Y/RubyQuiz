#!/usr/bin/env ruby
# Ruby Quiz 156: Internal Rate of Return
# Jesse Merriman

require 'rational'

# Guess a new number between a lower and upper bound.
def guess lower, upper
  if upper == 1.0/0.0
    lower < 0 ? 0.to_r : (lower + 1) * 2
  elsif lower == 1.0/0.0
    - guess(-upper, -lower)
  else
    (lower + upper) / 2
  end
end

def nvp cash_flows
  lambda do |irr|
    t = 0
    cash_flows.inject { |sum, c| t += 1; sum + c / (1 + irr) ** t }
  end
end

# Calculate the IRR to within 1 / 10**accuracy
def irr nvp, accuracy = 4
  lower, upper = -1.to_r, 1.0/0.0

  while (lower - upper).abs > Rational(1, 10 ** accuracy)
    g = guess lower, upper
    nvp[g] > 0 ? lower = g : upper = g
  end

  (lower + upper) / 2
end

class String
  def to_r
    if m = /^(\-?\d+)$/.match(self)
      m[1].to_i.to_r
    elsif m = /^(\-?\d+)\.(\d+)$/.match(self)
      m[1].to_i + Rational(m[2].to_i, 10 ** m[2].length)
    elsif m = /^(\-?\d+)\s*\/\s*(\d+)$/.match(self)
      Rational m[1].to_i, m[2].to_i
    else
      raise StandardError, "Can't parse #{self} to a Rational"
    end
  end
end

if __FILE__ == $0
  cash_flows = ARGV[0..-2].map { |x| x.to_r }
  accuracy = ARGV[-1].to_i

  nvp = nvp cash_flows
  if nvp[0] < nvp[1]
    puts 'Cannot find IRR.'
  else
    i = irr nvp, accuracy
    puts "irr: #{i} (#{i.to_f})"
  end
end
