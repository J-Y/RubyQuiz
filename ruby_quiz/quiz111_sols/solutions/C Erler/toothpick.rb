#!/usr/bin/env ruby

class String
  def toothpick_count
    count('|+*-') + count('+*')
  end
end

class Array
  def add_in operation
    each_with_index do |expression, i|
      (1..i).each do |j|
        position = i.__send__(operation, j)
        if (1...length).include? position
          combination = "#{ expression }#{ operation }#{ self[j] }"
          self[position] = combination if self[position] and combination.toothpick_count < self[position].toothpick_count
        end
      end unless i.zero?
    end
  end
end

def output number, expression
  puts "#{ expression.gsub /\*/, 'x' } = #{ number } (#{ expression.toothpick_count } toothpick#{ 's' unless expression.toothpick_count == 1 })"
end

result_wanted = ARGV.first.to_i

results = (0..result_wanted).map { |i| '|' * i }
results.add_in :*
results.add_in :+

output result_wanted, results[result_wanted]
