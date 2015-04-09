class Array
 def sum
   inject { |s,x| s + x }
 end
 def delete_one! n
   (i = index(n)) ? delete_at(i) : nil
 end
 def count n
   inject(0) { |c,x| x == n ? c+1 : c }
 end
end

class Knapsack
  def initialize target, numbers, avoid=Array.new
    @target,@numbers,@avoid = target, numbers,avoid.compact.uniq
  end
  def solve
    solver @numbers.map { |n| [n] }
  end
  def solver paths
    new_paths = Array.new # New paths will be stored here
    paths.uniq.each do |path| # For each path do
      return path if path.sum == @target && (!@avoid.include?path) # If it's a valid soulution and shouldn't be avoided return in
      @numbers.uniq.each do |n| # Add each number to the path
        # If we have numbers left to add to the path and the sum will not get greater then the target we want
        if (path.count(n)<@numbers.count(n)) && (path.sum+n <= @target)
          # Store the new path in our new new_path array if it shouldn't be avoided
          new_path = path.dup
          new_path << n
          unless @avoid.include?new_path
            new_paths << new_path unless new_path.sum == @target
            return new_path if new_path.sum == @target
          end
        end
      end
    end
    return nil if new_paths.empty? # We walked the whole tree and no new path has been found, return nil
    solver new_paths # Launch again with the new paths
  end
end

def find_split fair_split,loot,avoid=Array.new
  current_loot = loot.dup # Remember the loot before a split has been made
  stakes = Array.new
  # Try splitting the loot
  begin
    stake = Knapsack.new(fair_split,loot,avoid).solve
    stakes << stake
    stake.each { |s| loot.delete_one!(s) } unless stake.nil? # Remove from the loot what has been found
  end until stake.nil? || loot.empty? # Loop until the loot is empty, or the algorithm found no valid solution
  if loot.empty? # The whole loot is empty, a fair split has been found
    return stakes
  else
    if current_loot == loot # The algorithm splitted nothing, it's not possible to fairly split the loot
      return nil
    else # The algorithm splitted something, but it wasn't correct. Try again avoiding the already found solutions
     return find_split(fair_split,current_loot,stakes+avoid)
    end
  end
end

adventures,loot = ARGV.shift.to_i,ARGV.map { |a| a.to_i }

fair_split = loot.sum/adventures
stakes = (loot.sum%adventures).zero? ? find_split(fair_split,loot) : nil

if stakes.nil?
  puts "It is not possible to fairly split this treasure #{adventures} ways."
else
  stakes.size.times { |i| puts "#{i+1}: " + stakes[i].sort.join(" ") }
end
class Array
  def sum
    inject { |s,x| s + x }
  end
  def delete_one! n
    (i = index(n)) ? delete_at(i) : nil
  end
  def count n
    inject(0) { |c,x| x == n ? c+1 : c }
  end
end

class Knapsack
  def initialize target, numbers, avoid=Array.new
    @target,@numbers,@avoid = target, numbers,avoid.compact.uniq
  end
  def solve
    solver @numbers.map { |n| [n] }
  end
  def solver paths
    new_paths = Array.new # New paths will be stored here
    paths.uniq.each do |path| # For each path do
      return path if path.sum == @target && (!@avoid.include?path) # If it's a valid soulution and shouldn't be avoided return in
      @numbers.uniq.each do |n| # Add each number to the path
        # If we have numbers left to add to the path and the sum will not get greater then the target we want
        if (path.count(n)<@numbers.count(n)) && (path.sum+n <= @target)
	  # Store the new path in our new new_path array if it shouldn't be avoided
	  new_path = path.dup
	  new_path << n
	  unless @avoid.include?new_path
	    new_paths << new_path unless new_path.sum == @target
	    return new_path if new_path.sum == @target
	  end
	end
      end
    end
    return nil if new_paths.empty? # We walked the whole tree and no new path has been found, return nil
    solver new_paths # Launch again with the new paths
  end
end

def find_split fair_split,loot,avoid=Array.new
  current_loot = loot.dup # Remember the loot before a split has been made
  stakes = Array.new
  # Try splitting the loot
  begin
    stake = Knapsack.new(fair_split,loot,avoid).solve
    stakes << stake
    stake.each { |s| loot.delete_one!(s) } unless stake.nil? # Remove from the loot what has been found
  end until stake.nil? || loot.empty? # Loop until the loot is empty, or the algorithm found no valid solution
  if loot.empty? # The whole loot is empty, a fair split has been found
    return stakes
  else
    if current_loot == loot # The algorithm splitted nothing, it's not possible to fairly split the loot
      return nil
    else # The algorithm splitted something, but it wasn't correct. Try again avoiding the already found solutions
      return find_split(fair_split,current_loot,stakes+avoid)
    end
  end
end

adventures,loot = ARGV.shift.to_i,ARGV.map { |a| a.to_i }

fair_split = loot.sum/adventures
stakes = (loot.sum%adventures).zero? ? find_split(fair_split,loot) : nil

if stakes.nil?
  puts "It is not possible to fairly split this treasure #{adventures} ways."
else
  stakes.size.times { |i| puts "#{i+1}: " + stakes[i].sort.join(" ") }
end