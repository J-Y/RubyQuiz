class Array

  # converts a two-dimensional array into a multi-line string
  def to_s2
    map { |row| "#{row}\n" }.join
  end

  # inserts successive elements from other array between every two
  # elements of this array
  def weave other
    inject [] do |array, element|
      array << other.shift unless array.empty?
      array << element
    end
  end

  # weaves the rows of two two-dimensional arrays, see weave
  def weave2 other
    zip( other ).map { |row1, row2| row1.weave row2 }
  end

end


class String

  # splits a multi-line string into a two-dimensional array of
  # character strings
  def to_a2
    map { |row| row.chomp.split // }
  end

  # transposes a multi-line string like a two-dimensional array
  def transpose
    to_a2.transpose.to_s2
  end

  # in-place form of transpose
  def transpose!
    replace transpose
  end

  # like gsub!, but works both horizontally and vertically in a
  # multi-line string
  def gsub2! re, subst
    result1 = gsub! re, subst
    transpose!
    result2 = gsub! re, subst
    transpose!
    self if result1 || result2
  end

  # like Array#weave2, using multi-line strings
  def weave other
    to_a2.weave2( other.to_a2 ).to_s2
  end

end


# input patterns
FILLED = "X"
LETTER = "_"

# intermediate patterns
NUMBER = "N"
OUTSIDE = "O"
LINE = "#"
EMPTY = " "

# search patterns
OUT_OR_EDGE = /^|#{OUTSIDE}|$/
BEFORE_NEW_WORD = /^|#{OUTSIDE}|#{FILLED}/
WORD = /#{LETTER}|#{NUMBER}/


# removes spaces from input
def remove_spaces
  @s.gsub!( / /, "" )
end

# marks outside cells (filled cells adjacent to edges or outside cells)
def mark_outside_cells
  nil while \
    @s.gsub2!( /#{FILLED}(#{OUT_OR_EDGE})/, "#{OUTSIDE}\\1" ) or \
    @s.gsub2!( /(#{OUT_OR_EDGE})#{FILLED}/, "\\1#{OUTSIDE}" )
end

# marks beginnings of words
def number_beginnings
  @s.gsub2! /(#{BEFORE_NEW_WORD})#{LETTER}(#{WORD})/, "\\1#{NUMBER}\\2"
end

# creates a pattern of delimiters between non-outside cells
def delimiters s, delimiter, space, gsub_method = :gsub!
  r = s.dup
  r.send gsub_method, /^/, OUTSIDE
  r.send gsub_method, /[^#{OUTSIDE}\n]/, delimiter
  r.send gsub_method, /#{OUTSIDE}(?=#{delimiter})/, delimiter
  r.send gsub_method, OUTSIDE, space
  r
end

# duplicates every cell line, removing number marks
def duplicate_cell_lines
  index = 0
  @s = @s.inject do |result, row|
    index += 1
    result << row
    result << row.gsub( NUMBER, LETTER ) if index % 2 == 1
    result
  end
end


# read layout
@s = ARGF.read

# process the layout
remove_spaces
mark_outside_cells
number_beginnings

# delimiting lines and corners
v = delimiters @s, LINE, EMPTY
h = delimiters( @s.transpose, FILLED, LETTER ).transpose
c = delimiters @s, LINE, EMPTY, :gsub2!

# combine layout and delimiters
vs = v.weave @s
ch = c.weave h
@s = ch.transpose.weave( vs.transpose ).transpose

# format the result
duplicate_cell_lines
num = 0
@s.gsub! /./ do |char|
  case char
  when OUTSIDE, LETTER then "    "
  when FILLED then "####"
  when NUMBER then "%-4i" % ( num += 1 )
  else char
  end
end

# output the result
puts @s
