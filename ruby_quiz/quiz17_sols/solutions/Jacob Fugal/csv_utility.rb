#  return the formula offset calculations
#
#  used for embedding a formula into the csv file to be output to excel
#
#  @author         Jason E. Sweat
#  @translator     Jacob Fugal
#  @since          2002-05-01
#  @translated     2005-02-01
#
# Takes optional column/row offsets and returns a string representing the excel
# formula for a relative cell reference

def cell( column, row )
  row = row.to_i - 1
  column = column.to_i - 1

  'OFFSET($A$1,ROW()' +
  (row.zero? ? '' : "#{row < 0 ? '-' : '+'}#{row.abs}") +
  ',COLUMN()' +
  (column.zero? ? '' : "#{column < 0 ? '-' : '+'}#{column.abs}") +
  ')'
end

# And here is an example of the helper function in action, making a nicely
# formatted cell with a "safe" divide by zero.  Note this formula is created
# once, and then output wherever it is needed in the csv file (in each row,
# possibly for more than one column in each row, etc.).  It takes the column
# four to the left of this cell, and divides it by the column two to the left
# of this cell, and formats as a percent number.

# Formula for % weight.
puts "\"=TEXT(IF(#{c(-2)}=0,0,#{c(-4)}/#{c(-2)}),\"\"0.0%\"\")\"";
