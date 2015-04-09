class Xword
def initialize(spec)
  @spec   = spec.gsub(/ +/,'').squeeze("\n")
  @height = @spec.count("\n")
  @width  = (@spec.size - @height) / @height
end
def find_blanks
  1 while @spec.gsub!(/(^|B+)X/,'\1B')   ||
		  @spec.gsub!(/X(B+|$)/,'B\1')   ||
		  @spec.gsub!(/X(.*\Z)/,'B\1')   ||
		  @spec.gsub!(/\A(.*)X/,'\1B')   ||
		  @spec.gsub!(/X(.{#{@width}}B)/m,'B\1') ||
		  @spec.gsub!(/(B.{#{@width}})X/m,'\1B')
end
def generate(c="#")
  find_blanks
  row   = ((" " * 5) * @width) + " \n"
  @pstr = row * (@height * 3) + row
  @llen = row.size
  @cells = @spec.delete("\n")
  cell, count = -1, 0
  (0...@pstr.size - @llen * 3).step(@llen * 3) do |i|
	(i...i + @llen - 5).step(5) do |j|
	  cell += 1
	  make_cell(j, c) if @cells[cell] != ?B
	  fill_cell(j, c) if @cells[cell] == ?X
	  next unless blank?(cell) and numerate?(cell)
	  @pstr[j + @llen + 1, 2] = sprintf("%02d", count += 1)
	end
  end
end
def blank?(cell) 
  (0...@cells.size) === cell and @cells[cell] == ?_
end
def numerate?(cell)
  mod = cell % @width
  (mod == 0      or !blank?(cell - 1)) &&
  (mod <  @width and blank?(cell + 1)) or
  (!blank?(cell - @width) and blank?(cell + @width))
end
def make_cell(n,c)
  @pstr[n..n + 5] = c * 6
  @pstr[(n + @llen * 3)..((n + @llen * 3) + 5)] = c * 6
  4.times {|i| @pstr[n + @llen * i] = c}
  4.times {|i| @pstr[n + 5 + @llen * i] = c}
end
def fill_cell(n,c)
  @pstr[n + @llen + 1, 4]     = c * 4
  @pstr[n + @llen * 2 + 1, 4] = c * 4
end
def to_s
  @pstr
end
end

xword = Xword.new(File.read(ARGV[0]))
xword.generate('@')
puts xword
