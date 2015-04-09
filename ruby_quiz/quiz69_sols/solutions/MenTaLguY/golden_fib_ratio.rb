#!/usr/bin/ruby

CELL_WIDTH = 5
CELL_HEIGHT = 3

def box( size )
  width = size * CELL_WIDTH
  height = size * CELL_HEIGHT
  lines = ["#" * width] + ["##{ " " * ( width - 1 ) }"] * ( height - 1 )
  lines.map! { |line| line.dup }
end

lines = box( 1 )
p lines
$*[0].to_i.times do
  width = lines.first.size * CELL_HEIGHT
  height = lines.size * CELL_WIDTH
  if width > height
    lines.concat box( width / CELL_WIDTH / CELL_HEIGHT )
  else
    lines.zip box( height / CELL_WIDTH / CELL_HEIGHT ) do |line, box|
      line << box
    end
  end
end
lines.each { |line| puts "#{ line }#" }
puts "#{ lines.first }#"
