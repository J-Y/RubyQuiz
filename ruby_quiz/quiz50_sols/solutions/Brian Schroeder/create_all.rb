#!/usr/bin/ruby

Dir['examples/*.png'].sort.each do | file |
  puts file
  system "./asciiview.rb #{file} | tee - #{file}.txt"
  puts
end
