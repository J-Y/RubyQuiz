the_gradient = %w|D Y 8 S 6 5 J j t c + i ! ; : .|
###############PUT YOUR FILENAME
HERE#########################################
the_file = File.new('ducky.bmp', 'rb')
the_file.read(2) #BM
the_file.read(4).unpack('V')[0] #filesize
the_file.read(4) #unused
the_file.read(4).unpack('V')[0] #offset from beginning to bitmap data
the_file.read(4).unpack('V')[0] #size of bitmap header
image_x = the_file.read(4).unpack('V')[0] #width x in pixels
image_y = the_file.read(4).unpack('V')[0] #height y in pixels
the_file.read(2).unpack('v')[0] #planes?
the_file.read(2).unpack('v')[0] #bits per pixel
the_file.read(24) #unused

the_bitmap = []
puts "CRRRRUNCHHHH --- please wait, reading file..."
image_y.times do |row|
the_bitmap[row] = []
image_x.times do |col|
the_bitmap[row][col] = MyPixel.new( 0, 0, 0 )
the_bitmap[row][col].b = the_file.read(1).unpack('c')[0]
the_bitmap[row][col].g = the_file.read(1).unpack('c')[0]
the_bitmap[row][col].r = the_file.read(1).unpack('c')[0]
end
end

puts "output coming:"
the_output = File.new('output.asciiart', 'w')
(image_y-1).downto(0) do |row|
image_x.times do |col|
the_avg =
(the_bitmap[row][col].b+the_bitmap[row][col].g+the_bitmap[row][col].r)/3
the_output.write(the_gradient[the_avg>>4])
end
the_output.write("\n")
end
