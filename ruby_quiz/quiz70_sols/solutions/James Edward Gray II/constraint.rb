#!/usr/local/bin/ruby -w

class Problem
  def initialize
    @vars    = Hash.new { |vars, name| vars[name] = Array.new }
    @rules   = Hash.new { |rules, var| rules[var] = Array.new }
    
    yield self if block_given?
  end
  
  def var( name, *choices )
    if choices.empty?
      values = @vars[name]
      values.size == 1 ? values.first : values
    else
      @vars[name].push(*choices)
    end
  end
  
  def rule( name, &test )
    @rules[name] << test
  end
  
  def solve
    loop do
      changed = false
      @vars.each do |name, choices|
        next if choices.size < 2

        failures = choices.select do |choice|
          @rules[name].any? { |rule| !rule[choice] }
        end
        unless failures.empty?
          @vars[name] -= failures
          changed = true
        end
      end

      break unless changed
    end

    self
  end
end

def problem( &init )
  Problem.new(&init).solve
end
