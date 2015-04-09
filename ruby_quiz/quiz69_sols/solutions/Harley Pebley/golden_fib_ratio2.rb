#
# Version 2
#
$eol = '~'
$corner = '+'
$horiz = '-'
$vert = '|'
$white = ' '

def ascii_square(aSize)
  if aSize < 2 then
    result = $corner
  else
    i = 0
    result = ''
    aSize.times do
      i = i + 1
      if (i == 1) or (i == aSize) then
        result = result + $corner + $horiz * (aSize-2) + $corner + $eol
      else
        result = result + $vert + $white * (aSize-2) + $vert + $eol
      end
    end
    result.chop!
  end
  result
end

def gen_squares(aSizes)
  result = []
  aSizes.each do |lSize|
    result.push(ascii_square(lSize))
  end
  result
end

def fibonacci(aFibs, aDepth)
  if aFibs.length < aDepth then
    if aFibs.length < 2 then
      aFibs.push(1)
    else
      aFibs.push(aFibs[aFibs.length-1] + aFibs[aFibs.length-2])
    end
    fibonacci(aFibs, aDepth)
    aFibs
  end
end

if ARGV.empty? then
  lDepth = rand(10)+1
else
  lDepth = ARGV[0].to_i
end

lFibs = fibonacci([], lDepth)
boxes = gen_squares(lFibs)
output = []
boxes.each do |box|
  lines = box.split($eol)
  if (output.length == 0) or (lines.length == output.first.length) then
    lines.each do |inLine|
      output.push(inLine)
    end
  else
    i = 0
    output.length.times do
      output[i] = output[i]+lines[i]
      i = i + 1
    end
  end
end
puts output
