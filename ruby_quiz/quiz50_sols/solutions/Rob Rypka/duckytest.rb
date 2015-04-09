require 'RMagick'
require 'yaml'

### handle settings

$src = ARGV[0]  # source image
$out = ARGV[1]  # destination file
$opt_num = ARGV[2].to_i  # a character = num x num pixels
$opt_norm = ARGV[3]  # normalized soruce?

### import table and source
table = YAML::load(File.open("i2a.#{$opt_num.to_s}.yaml"))
srcimg = Magick::Image.read($src)[0]
# fudge the aspect ratio - should do this a different (more exact) way
srcimg.scale!(srcimg.columns * 1.5, srcimg.rows)
srcarr = srcimg.export_pixels(0, 0, srcimg.columns, srcimg.rows, "I")

# normalize the table and srcarray
if $opt_norm
  src_min = srcarr.min
  src_max = srcarr.max

  srcarr.collect! { |x| ((x - src_min) *  255) / (src_max - src_min) }
end

### new methods 'n' stuff
class Array
  # access to a clump by location (of character)
  def clump(x, y, img)
    result = []
    $opt_num.times { |i|
      start = x * $opt_num + (y * $opt_num + i) * img.columns
      result += self[start, $opt_num]
      #puts start.to_s + ", " + i.to_s
    }
    result
  end
end



### find 'closest' character
def dist(a, b)
  sum = 0
  a.length.times { |i|
    sum += (a[i] - b[i])**2
  }
  Math.sqrt(sum)
end


def closest_char(clump, table)
  closest = 255 * $opt_num  # 
  result = []
  table.each { |code, value|
    d = dist(clump, value)
    if d == closest
      result += [code]
    elsif d < closest
      result = [code]
      closest = d
    end
  }
  result[rand(result.length)]
end


### write the results
outfile = File.new($out, "w")

# skip extraneous border pixels by using integer division
new_width = srcimg.columns / $opt_num
new_height = srcimg.rows / $opt_num

new_height.times do |i|
  new_width.times do |j|
    ch = " "
    ch[0] = closest_char(srcarr.clump(j, i, srcimg), table)
    outfile.print ch
  end
  outfile.print "\n"
end
