# Ruby Quiz #14 - LCD Display
# Laurent Julliard <laurent at moldus dot org>
#
digits = [[' - ','|.|',' . ','|.|',' - '],
          [' . ',' .|',' . ',' .|',' . '],
          [' - ',' .|',' - ','|. ',' - '],
          [' - ',' .|',' - ',' .|',' - '],
          [' . ','|. ',' - ',' .|',' . '],
          [' - ','|. ',' - ',' .|',' - '],
          [' - ','|. ',' - ','|.|',' - '],
          [' - ',' .|',' . ',' .|',' . '],
          [' - ','|.|',' - ','|.|',' - '],
          [' - ','|.|',' - ',' .|',' - ']]
if ARGV[0] == "-s"
  s = ARGV[1].to_i; stg = ARGV[2]
else
  s = 1 ; stg = ARGV[0]
end
aff = []
stg.each_byte do |c|
  aff << digits[c-48].collect { |l| l.sub(/\./,' '*s).sub(/-/,'-'*s) }
end
(aff = aff.transpose).each_index do |i|
  puts((aff[i].join(' ')+"\n")*(i%2 == 1 ? s : 1))
end
