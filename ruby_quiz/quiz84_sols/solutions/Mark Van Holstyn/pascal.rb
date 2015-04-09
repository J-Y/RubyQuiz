rows = ( ARGV.shift || 1 ).to_i
tri = Array.new( rows ) { |i| Array.new( i+1 ) }
tri.each_with_index do |row, rowno|
   row.fill do |colno|
       ( colno == 0 or colno == rowno ) ? 1 : tri[rowno-1][colno-1] +
tri[rowno-1][colno]
   end
end

cols, col_w = tri.last.length, tri.last.max.to_s.length+1
tri.each do |row|
   row_strs = row.collect { |col| col.to_s.center( col_w ) }
   puts row_strs.join.center( cols*col_w )
end
