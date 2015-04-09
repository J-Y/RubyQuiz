#!/usr/local/bin/ruby -w

require "constraint"

# sudoku conveniences
indices = (0..8).to_a
boxes   = Hash.new
[(0..2), (3..5), (6..8)].each do |across|
  [(0..2), (3..5), (6..8)].each do |down|
    squares = across.map { |x| down.map { |y| "#{x}#{y}" } }.flatten
    squares.each { |square| boxes[square] = squares - [square] }
  end
end

solution = problem do |prob|
  # read puzzle, setting problem variables from data
  (ARGV.empty? ? DATA : ARGF).each_with_index do |line, y|
    line.split.each_with_index do |square, x|
      prob.var("#{x}#{y}", *(square =~ /\d/ ? [square.to_i] : (1..9)))
    end
  end
  
  # apply the rules of the game
  indices.each do |x|
    indices.each do |y|
      col = (indices - [y]).map { |c| "#{x}#{c}" }  # other cells in column
      row = (indices - [x]).map { |r| "#{r}#{y}" }  # other cells in row
      box = boxes["#{x}#{y}"]                       # other cells in box
      [col, row, box].each do |set|  # set rules requiring a cell to be unique
        prob.rule("#{x}#{y}") { |n| !set.map { |s| prob.var(s) }.include?(n) }
      end
    end
  end
end

# pretty print the results
puts "+#{'-------+' * 3}"
indices.each do |y|
  print "| "
  indices.each do |x|
    print "#{solution.var("#{x}#{y}").inspect} "
    print "| " if [2, 5].include? x
  end
  puts "|"
  puts "+#{'-------+' * 3}" if [2, 5, 8].include? y
end

__END__
7 _ 1 _ _ _ 3 _ 5
_ 8 _ 1 _ 5 _ 6 _
2 _ _ _ _ _ _ _ 9
_ _ 6 5 _ 1 2 _ _
_ 3 _ _ _ _ _ 1 _
_ _ 8 3 _ 4 9 _ _
9 _ _ _ _ _ _ _ 8
_ 2 _ 6 _ 9 _ 4 _
6 _ 5 _ _ _ 7 _ 1
