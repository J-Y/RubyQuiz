#!/usr/bin/env ruby -w

cards = (1..13).to_a

start_card = ARGV.shift.to_i
if start_card.between? 1, 13
  cards.push(cards.shift) until cards.first == start_card
end

cards.each do |card|
  $stdin.gets # competition card--ignored
  $stdout.puts card
  $stdout.flush
  $stdin.gets # opponent's bid--ignored
end
