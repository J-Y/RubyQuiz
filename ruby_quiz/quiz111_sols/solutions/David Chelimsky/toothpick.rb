#toothpick.rb
class Fixnum
  def to_t
    toothpick_expression.to_s
  end
  
  def toothpick_count
    toothpick_expression.toothpick_count
  end
  
  def toothpick_expression
    @toothpick_expression ||= ToothpickExpression.find_short_expression(self)
  end
end

class ToothpickExpression
  def initialize(n,s)
    @n = n
    multipliers << @n/s
    multipliers << s if s > 1
  end

  def to_s(numeric=false)
    ms = multipliers.collect { |m| numeric ? m.to_s : no_math_expression(m)}
    result = numeric ? ms.join("*") : ms.join("x")
    remainder_expression = ToothpickExpression.find_short_expression(remainder)
    result << "+" << remainder_expression.to_s(numeric) unless remainder == 0
    result
  end
  
  def multipliers
    @multipliers ||= []
    @multipliers.delete(1)
    @multipliers << 1 if @multipliers.empty?
    @multipliers.sort!
  end

  def no_math_expression(n)
    (1..n).inject("") { |result,n| result << "|" }
  end
  
  def remainder
    ms = multipliers.collect { |m| m.to_s }
    expression = ms.join("*")
    @n - eval(expression)
  end
  
  def toothpick_count
    return to_s.split('').inject(0) do |v,c|
      v = v + 1 if c == '|'
      v = v + 2 if ['+','x'].include?(c)
      v
    end   
  end

  def self.find_short_expression(n)
    expression = self.find_candidate_short_expression(n)
    expression.expand_multipliers
    expression.contract_multipliers
    expression
  end
    
  def self.find_candidate_short_expression(n)
    candidate = ToothpickExpression.new(n, 1)
    (2..n).each do |i|
      break if i > n/i
      potential_candidate = ToothpickExpression.new(n, i)
      if potential_candidate.has_fewer_toothpicks_than?(candidate) or 
          (
            potential_candidate.has_as_many_toothpicks_as?(candidate) and
            potential_candidate.has_more_multipliers_than?(candidate)
          )
        candidate = potential_candidate
      end
    end
    candidate
  end
  
  def has_fewer_toothpicks_than?(other)
    toothpick_count < other.toothpick_count
  end
  
  def has_as_many_toothpicks_as?(other)
    toothpick_count == other.toothpick_count
  end
  
  def has_more_multipliers_than?(other)
    multipliers.length > other.multipliers.length
  end

  def expand_multipliers
    done_expanding = false
    until (done_expanding)
      done_expanding = :possibly
      multipliers.clone.each do |e|
        sub_expression = ToothpickExpression.find_candidate_short_expression(e)
        if sub_expression.multipliers.length > 1
          multipliers.delete(e)
          sub_expression.multipliers.each {|m| multipliers << m }
          done_expanding = false
        end
      end
    end
  end

  def contract_multipliers
    done_contracting = false
    until (done_contracting)
      done_contracting = :possibly
      if multipliers[0] == 2
        if multipliers.length > 1 && multipliers[1] <= 3
          multipliers << (multipliers.shift*multipliers.shift)
          done_contracting = false
        end
      end
    end
  end
end

def convert(n)
  "#{n}: #{n.to_t} (#{n.toothpick_count} toothpick#{n == 1 ? '' : 's'} - #{n.toothpick_expression.to_s(:numeric)})"
end

if ARGV[0].to_i > 0
  if ARGV.length > 1
    (ARGV[0].to_i..ARGV[1].to_i).each do |n|
      puts convert(n)
    end
  else
    puts convert(ARGV[0].to_i)
  end
else
  puts <<-USAGE
This program will try to find the toothpick expression that
uses the least number of toothpicks for any positive integer.

You can tell it to process one number or a range of numbers:

  $ruby toothpick.rb 37
  $ruby toothpick.rb 37 362
  
USAGE
end