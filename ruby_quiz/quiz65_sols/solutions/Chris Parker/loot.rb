class Array
  def delete_one(item)
    return unless include?(item)
    index = nil
    self.each_with_index{|elem,index|break if elem == item}
    delete_at(index)
  end

  def delete_set(arry_to_delete)
    arry_to_delete.each{|elem| self.delete_one(elem)}
  end
end

def subset_sum(set, goal)
  return nil if set == [] and goal != 0
  return [] if goal == 0
  if goal >= set[0]
    ret_val = subset_sum(set[1..-1],goal - set[0])
    return ret_val << set[0] if ret_val != nil
  end
  return subset_sum(set[1..-1],goal)
end

if ARGV.length < 2
  print "Invalid arguments\n#{__FILE__} #adventurers list of booty\n"
  exit
end

num_people = ARGV[0].to_i

treasures = []
ARGV[1..-1].each do |num_string|
  treasures << num_string.to_i
end

total_treasure = treasures.inject(0){|sum, i| sum + i}

if total_treasure % num_people != 0 || num_people > treasures.length ||
treasures.max > total_treasure / num_people
  print "impossible to split treasure equally"
  exit
end

treasures = treasures.sort.reverse
num_people.times do |i|
  subset = subset_sum(treasures, total_treasure / num_people)
  if subset == nil
    print "can't split treasure evenly\n"
    exit
  else
    print "pirate #{i}: got #{subset.inject(""){|string, num|string+num.to_s+" "}}\n"
  end
  treasures.delete_set(subset)
end
