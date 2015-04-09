require 'RMagick'
require 'generator'
require 'enumerator'

puts "Usage: #{$0} <img> [size]" or exit if !ARGV[0]

img, size = Magick::ImageList.new(ARGV[0]), (ARGV[1]||40).to_f
factor = [size*1.5/img.rows, size/img.columns].min

img.resize!(img.columns*factor, 2*(img.rows*factor*0.75).round)
img = img.edge.despeckle.despeckle.normalize.threshold(50)

pixels = img.get_pixels(0, 0, img.columns, img.rows).map{|c| c.red.zero?}

pixels.to_enum(:each_slice, img.columns).each_slice(2) do |l|
  puts SyncEnumerator.new(*l).map{|p1, p2|
    [' ', "'", ".", ":"] [(p1 ? 0 : 1) + (p2 ? 0 : 2)]}.join('')
end
