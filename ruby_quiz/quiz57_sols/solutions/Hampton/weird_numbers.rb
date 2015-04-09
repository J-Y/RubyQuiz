def weirdo_exhaustive(from, max)
  puts "none found" and return 0 if max < 70
  (from..max).each do |num|
    if num % 2 == 0
      list, sum= [], 0
      (1...num).each do |div|
        list << div and sum += div if num % div == 0
      end
      puts "==" + num.to_s if sum > num and has_sum(num, list) == false
    end
  end
end

def has_sum(num, array)
  if array.is_a? Integer then return false end
  sum = 0
  array.each do |val| sum += val end
  if sum === num then return true end
  #this next line saves a BUNCH of checks.
  if sum < num then return false end
  array.each do |removeme|
    copy = array.dup
    copy.delete(removeme)
    if copy.size > 1 and has_sum(num, copy) == true then return true end
  end
  return false
end

def weirdo_fast(max)
  list = [ 70,836,4030,5830,7192,7912,9272,10792,17272,45356,73616, #
	83312,91388,113072,243892,254012,338572,343876,388076,  #
        519712,539744,555616,682592,786208,1188256,1229152,1713592, #
        1901728,2081824,2189024,3963968 ]
  list.each do |num|
    puts num if num <= max
  end
  if max > list[list.size-1] then weirdo_exhaustive(list[list.size-1], max) end
end
