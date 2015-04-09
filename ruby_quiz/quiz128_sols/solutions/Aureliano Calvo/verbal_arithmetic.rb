#!/usr/bin/env ruby

require 'set'

class String
  def char(index)
    self[index..index]
  end

  def value( mapping )
    size = self.length
    (0...self.length).inject(0) { |value, index| value += mapping[self.char(index)] * (10 ** (size - (index + 1))) }
  end
end

class Solver
  attr_reader :non_zero_chars, :zeroable_chars, :equation

  def initialize( *equation )
    char_set = Set.new
    equation.each { |term| (0...term.length).each { |index| char_set.add( term.char(index) ) } }
    @non_zero_chars = equation.inject( Set.new ) { |set, term| set.add( term.char(0) ) }
    @zeroable_chars = char_set - non_zero_chars
    @equation = equation
  end

  def mappings
    Mappings.new( @non_zero_chars, @zeroable_chars ) 
  end

  def solve
    mappings.find do 
      |mapping| 
      equation[equation.length - 1].value(mapping) == 
        (0...(equation.length - 1)).inject(0) {|acum, index| acum += equation[index].value(mapping) } 
    end
  end
end

class Mappings
  def initialize( non_zero_chars, zeroable_chars ) 
    @chars = non_zero_chars.to_a + zeroable_chars.to_a
    @non_zero_count = non_zero_chars.size
  end

  def find( mapping={}, &condition )
    if mapping.size == @chars.size then
      found = condition[mapping]
      return found ? mapping : nil
    else
      position = mapping.size
      start = position < @non_zero_count ? 1 : 0
      values = Set.new( start..9 ) - mapping.values
      new_mapping = Hash[ mapping ]
      values.each do
        |value|
        new_mapping[ @chars[position] ] = value
        result = find(new_mapping, &condition)
        return result if result
      end
      return nil
    end
  end
end

solution = Solver.new( *ARGV[0].split(/[+=]/ ) ).solve
if (solution) then
  solution.each_pair {|k,v| puts "#{k}: #{v}"}
else 
  puts "No solution found"
end