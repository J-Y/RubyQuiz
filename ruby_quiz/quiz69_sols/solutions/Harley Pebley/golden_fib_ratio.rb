#
# Version 1
#
$eol = '~'
$corner = '+'
$horiz = '-'
$vert = '|'
$white = ' '

def gen_fib_box(aStart, aLevel, aCount)
  if aLevel < aCount then
    if aStart.length < 2 then
      lNewBox = $corner
    else
      lLastSize = aStart[aStart.length-1].split($eol).first.length
      lNextToLastSize = aStart[aStart.length-2].split($eol).first.length
      lNewSize = lLastSize + lNextToLastSize
      i = 0
      lNewBox = ''
      lNewSize.times do
        i = i + 1
        if (i == 1) or (i == lNewSize) then
	  lNewBox = lNewBox + $corner + $horiz * (lNewSize-2) + $corner + $eol
        else
	  lNewBox = lNewBox + $vert + $white * (lNewSize-2) + $vert + $eol
        end
      end
      lNewBox.chop!
    end
    aStart.push(lNewBox)
    gen_fib_box(aStart, aLevel+1, aCount)
    aStart
  end
end

if ARGV.empty? then
  lDepth = rand(10)+1
else
  lDepth = ARGV[0].to_i
end

boxes = gen_fib_box([], 0, lDepth)
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
