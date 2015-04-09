#!/usr/bin/env ruby

require 'set'

def combinations sequence, n, unique=false
  return [] if n == 0
  return sequence if n == 1
  result = []

  (0...sequence.length).collect.each do |i|
    sub_sequence = sequence[(i + 1)..-1]
    sub_sequence += sequence[0..i] if unique

    combinations(sequence[(i + 1)..-1], n - 1).each do |smaller|
      result << ([sequence[i]] + [smaller]).flatten
    end
  end

  result
end

def chess_positions i=961
  def remaining subset
    (Set.new(0..7) - Set.new(subset)).collect
  end

  positions, n = [], 1

  combinations((0..7).collect, 3).each do |rooks_king|
    combinations(remaining(rooks_king), 2).each do |bishops|
      next if (bishops[0] + bishops[1]) % 2 == 0

      position = rooks_king + bishops
      remaining(position).each do |queen|
        non_knights = position + [queen]
        positions << non_knights + remaining(non_knights)

        return positions[-1] if n == i
        n += 1
      end
    end
  end
  return positions
end

def pretty_position position
  pieces, pos_hash = ['R', 'K', 'R', 'B', 'B', 'Q', 'N', 'N'], {}
  0.upto(7) {|i| pos_hash[(position[i] + 97).chr] = pieces[i]}

  sorted_keys = pos_hash.keys.sort
  sorted_vals = (0..7).collect.map {|i| pos_hash[sorted_keys[i]]}

  pretty_pos = "White:\n"
  sorted_keys.each {|key| pretty_pos += "#{key} "}
  pretty_pos += "\n"
  sorted_vals.each {|val| pretty_pos += "#{val} "}

  pretty_pos
end

puts pretty_position(chess_positions(48))
