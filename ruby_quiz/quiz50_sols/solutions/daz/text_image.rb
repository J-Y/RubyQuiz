Gradient = %w{ D Y 8 S 6 5 J j t c + i ! ; : . }

# http://www.d10.karoo.net/ruby/quiz/50/duck.bmp  (NOTE: 800KB  BMP)
bmp = File.open('duck.bmp', 'rb') { |fi| fi.read }
bmo = bmp[10, 4].unpack('V')[0]             # offset to bitmap data
image_x, image_y = bmp[18, 8].unpack('VV')  # width x / height y (pixels)
by_start = bmo + ((image_y - 1) * (image_x * 3))

File.open('output.txt', 'w') do |fo|
  by_start.step(bmo, -(image_x * 3)) do |by_ptr|
    image_x.times do |x|
      t = 0;  3.times {|n| t += bmp[by_ptr + (x * 3) + n] }
      fo.putc( Gradient[ (t / 3 ) >> 4 ] )
    end
    fo.puts
  end
end
