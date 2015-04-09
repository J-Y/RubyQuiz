$thegrid = []

# creates the grid
# inserts 1 for positions that should be filled later on,
# sets it to 0 otherwise
def create_grid
  # array with all allowed columns
  cache = (1..7).map{|i| Array.new(3) {|j| i[j]}.reverse! }
  rowcounter = [0,0,0]

  # step through each colum, choosing a random valid column from cache
  # deletes all rows from cache that lead to invalid solutions
  0.upto(8) do |column|
    $thegrid[column] = cache[ rand(cache.length) ].clone

    # number of values uses so far per row
    rowcounter = rowcounter.zip($thegrid[column]).map!{|i,j| i+j}

    # test constraints and delete invalid columns from later selection
    0.upto(2) do |count|
      cache.delete_if {|x| x[count] == 1} if rowcounter[count] == 5
      cache.delete_if {|x| x[count] == 0} if 8 - column == 5 - rowcounter[count]
    end

    total = rowcounter.inject{|sum, n| sum + n}
    cache.delete_if {|x| total + x.inject{|sum, n| sum + n} > 8 + column }
  end
end

# fills the grid with random values, increasing order per column
def fill_grid
  $thegrid.each_with_index do |line, i|
    start = (i==0) ? 1 : i*10
    stop = (i==8) ? 90 : ((i+1)*10 - 1)
    count = line.inject {|sum, n| sum + n }

    line.each_with_index do |n, j|
      if n > 0 then
        $thegrid[i][j] = rand(stop - start - count + 2) + start
        start = $thegrid[i][j] + 1 #increasing numbers
        count -= 1
      end
    end
  end
end

create_grid
fill_grid

# pretty print the grid
sep = "+----"*9 + "+\n"
puts $thegrid.transpose.inject(sep) {|str, e|
  str += sprintf("| %2d "*9 + "|\n" + sep, *e).gsub(/ 0/, "  ")
}
