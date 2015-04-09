#!/usr/bin/env ruby

class String
  def toothpick_count
    count('|-') + 2*count('+*')
  end

  def toothpick_value
    if count('|').zero?
      0
    else
      eval(gsub(/(\+|\*|-|\Z)/, ')\1').gsub(/(\A|\+|\*|-)\|/, '\1(1').gsub(/\|/, '+1'))
    end
  end

  def toothpick_information
    "#{ gsub /\*/, 'x' } = #{ toothpick_value } (#{ toothpick_count } toothpick#{ 's' unless toothpick_count == 1 })"
  end
end

class Array
  def add_in operation
    1.upto(length - 1) do |i|
      1.upto(i) do |j|
        position = i.__send__(operation, j)
        if (1...length).include? position
          combination = "#{ self[i] }#{ operation }#{ self[j] }"
          self[position] = combination if combination.toothpick_count < self[position].toothpick_count
        end
      end
    end
  end
end

results = Array.new(ARGV.first.to_i + 1) { |i| '|' * i }
results.add_in :*
results.add_in :+
puts results.last.toothpick_information
