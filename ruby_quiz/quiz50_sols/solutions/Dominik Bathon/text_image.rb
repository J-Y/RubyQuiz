GRADIENT = %w|D Y 8 S 6 5 J j t c + i ! ; : .|
file = File.new(ARGV.shift || "ducky.bmp", "rb")
file.read(2+4+4+4+4) # headers
image_x, image_y = file.read(8).unpack("VV") # width / height
file.read(2+2+24) # headers

puts((0...image_y).collect do |row|
  (0...image_x).collect do |col|
    GRADIENT[(file.read(3).unpack("CCC").inject { |a,b| a+b } / 3) >> 4]
  end.join
end.reverse)
