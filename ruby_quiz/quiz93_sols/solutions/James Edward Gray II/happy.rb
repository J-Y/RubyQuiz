#!/usr/bin/env ruby -w

UNHAPPY = [0, 4, 16, 20, 37, 42, 58, 89, 145].freeze

happy = Hash.new do |found, num|
  digits    = num.to_s.split("").sort.map { |d| d.to_i }.
                                      delete_if { |d| d.zero? }
  happiness = digits.inject(0) { |sum, d| sum + d * d }
  found[num] = if happiness == 1
    true
  elsif UNHAPPY.include? happiness
    false
  else
    found[happiness]
  end
end

(1..100_000).each { |n| p n if happy[n] }
