#!/usr/bin/env ruby -wKU

EQUATION = ARGV.shift.to_s.downcase.sub("=", "==")
LETTERS  = EQUATION.scan(/[a-z]/).uniq
CHOICES  = LETTERS.inject(Hash.new) do |all, letter|
  all.merge(letter => EQUATION =~ /\b#{letter}/ ? 1..9 : 0..9)
end

def search(choices, mapping = Hash.new)
  if choices.empty?
    letters, digits = mapping.to_a.flatten.partition { |e| e.is_a? String }
    return mapping if eval(EQUATION.tr(letters.join, digits.join))
  else
    new_choices = choices.dup
    letter      = new_choices.keys.first
    digits      = new_choices.delete(letter).to_a - mapping.values
    
    digits.each do |choice|
      if result = search(new_choices, mapping.merge(letter => choice))
        return result
      end
    end
    
    return nil
  end
end

if solution = search(CHOICES)
  LETTERS.each { |letter| puts "#{letter}: #{solution[letter]}" }
else
  puts "No solution found."
end
