require 'RMagick'
require 'yaml'

### handle settings

$opt_ext = ARGV[1]  # extended ASCII?
$opt_num = ARGV[0].to_i  # a character = num x num pixels

### convert each letter to a set of values

# use common image structure for drawing
$canvas = Magick::Image.new($opt_num * 4, $opt_num * 4)
$draw = Magick::Draw.new
$draw.font = "Courier New Bold"
$draw.font_family = "Courier New"
$draw.font_weight = 900
$draw.pointsize = $opt_num * 4
$draw.gravity = Magick::CenterGravity

def get_values(code)
  char = " "
  char[0] = code
  $canvas.erase!
  $draw.annotate($canvas, 0, 0, 0, 0, char)
  # $canvas.write("images/#{code.to_s}.bmp")
  $canvas.scale(0.25).export_pixels(0, 0, $opt_num, $opt_num, "I")
end


### create the table of sets of values
table = Hash.new

(32..126).each { |code| table[code] = get_values(code) }

### create the table of sets of values
table = Hash.new

(32..126).each { |code| table[code] = get_values(code) }
(128..254).each { |code| table[code] = get_values(code) } if $opt_ext


### normalize
# hash min/max returns [key, value] for each a and b
table_min = (table.min { |a, b| a[1].min <=> b[1].min })[1].min
table_max = (table.max { |a, b| a[1].max <=> b[1].max })[1].max

table.each_value { |v| v.collect! { |x| ((x - table_min) *  255) / (table_max - table_min) } }


### write the table to a file(128..254).each { |code| table[code] = get_values(code) } if $opt_ext


### normalize
# hash min/max returns [key, value] for each a and b
table_min = (table.min { |a, b| a[1].min <=> b[1].min })[1].min
table_max = (table.max { |a, b| a[1].max <=> b[1].max })[1].max

table.each_value { |v| v.collect! { |x| ((x - table_min) *  255) / (table_max - table_min) } }


### write the table to a file

outfile = File.new("i2a.#{$opt_num.to_s}.yaml", "w")
YAML::dump(table, outfile)
