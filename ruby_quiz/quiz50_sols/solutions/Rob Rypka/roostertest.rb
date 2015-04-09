require 'RMagick'

rooster = Magick::Image.read("rooster.gif")[0]

# 1
rooster.scale(0.5).write("rooster1.png")
`ruby i2a.rb rooster1.png rooster1.txt 1 yes`

# 2
rooster.write("rooster2.png")
`ruby i2a.rb rooster2.png rooster2.txt 2 yes`

# 4
# rooster.write("rooster4.png")
# `ruby i2a.rb rooster4.png rooster4.txt 2 yes`
