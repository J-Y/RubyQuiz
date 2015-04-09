# Weird Numbers
# Simon Strandgaard  <neoneye@gmail.com>

def divisors(value)
  ary = []
  (value/2).times do |i|
    div = i + 1
    ary << div if value % div == 0
  end
  ary
end

$bits = []
32.times do |bit|
  $bits << 2 ** bit
end

def has_subset_equal_to(divs, value)
  pairs = divs.zip($bits)
  1.upto(2 ** divs.size - 1) do |i|
    sum = 0
    pairs.each{|div,b| sum+=div if (i&b)>0 }
    return true if sum == value
  end
  false
end

def find_weird_numbers(range_min, range_max)
  ary = []
  range_min.upto(range_max) do |value|
    divs = divisors(value)
    sum = divs.inject(0){|a,b|a+b}
    ary << [value, divs] if sum > value
  end
  res = []
  ary.each do |value, divs|
    if !has_subset_equal_to(divs, value)
      puts "##{value} is a WEIRD NUMBER"
      res << value
    else
      puts "##{value} is nothing"
    end
  end
  p res
end

p find_weird_numbers(1, 100)
