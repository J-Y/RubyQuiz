@ticket = (0..8).map{|col| (col*10..(col+1)*10-1).to_a.sort_by{rand}[0,3]}
(0..2).each do |row|
  (0..8).find_all do |i|
    @ticket[i].compact.size > 1
  end.sort_by{rand}[0,4].each do |col|
    @ticket[col][row] = nil
  end
end
