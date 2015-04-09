$snum = {
    1 => 'one', 2 => 'two', 3 => 'three', 4 => 'four', 5 => 'five', 6 => 'six',
    7 => 'seven', 8 => 'eight', 9 => 'nine', 10 => 'ten', 11 => 'eleven',
    12 => 'twelve', 13 => 'thirteen', 14 => 'fourteen', 15 => 'fifteen',
    16 => 'sixteen', 17 => 'seventeen', 18 => 'eighteen', 19 => 'nineteen',
    20 => 'twenty', 30 => 'thirty', 40 => 'forty', 50 => 'fifty', 60 => 'sixty',
    70 => 'seventy', 80 => 'eighty', 90 => 'ninety'
    }

def spelledNumber(x)
  if x >= 100
    print "must be 99 or less"
    exit
  elsif x <= 20
    $snum[x]
  else
    tens = (x / 10).to_i * 10
    if x - tens == 0
      $snum[x]
    else
      $snum[tens] + "-" + $snum[x - tens]
    end
  end
end

def checkIfTrue(s)
  realCount = {}
  LETTERS.each do |c|
    realCount[c] = s.count(c)
  end 
  if $fixedCount == realCount
    puts "Found it:"
    puts s
    exit
  end
  $fixedCount.each do |key, value|
    x = s.count(key)
    y = value
    $fixedCount[key] = randomizer(x, y)
  end
  $fixedCount
end

def randomizer(x, y)
  if x == y then return x end
  if x > y then x, y = y, x end
  rand(y-x+1)+x
end 

LETTERS = ('a'..'z').to_a
seed = %q/darrens ruby panagram program found this sentence which contains exactly and /
$fixedCount = {}
LETTERS.each { |c| $fixedCount[c] = rand(50) }

while 1
  (1..10000).each do
    s = seed
    LETTERS.each do |c|
      s += spelledNumber($fixedCount[c])
      s += " '#{c}'"
      s += $fixedCount[c] >= 2 ? "s, " : ", "
    end
    $fixedCount = checkIfTrue(s)
  end
  print "\t10K blip...\n"
end
