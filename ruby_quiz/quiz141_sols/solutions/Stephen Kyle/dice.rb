$desired_count = 0
$possible_count = 0

# argument "parsing" fun, delicate
verbose = true if ARGV[0] == "-v"
sample = true if ARGV[0] == "-s"
if sample or verbose
        dice = ARGV[1] if ARGV[1] =~ /\d+/
        desired = ARGV[2] if ARGV[2] =~ /\d+/
        hunted = ARGV[3] if ARGV[3] =~ /\d+/
else
        dice = ARGV[0] if ARGV[0] =~ /\d+/
        desired = ARGV[1] if ARGV[1] =~ /\d+/
        hunted = ARGV[2] if ARGV[2] =~ /\d+/
end
dice = dice.to_i
desired = desired.to_i

def nextLogicalRoll(array) # find the next "logical" set of dice
        seek = (array.length-1)
        if array[seek] != 6
                array[seek] += 1
        else
                while array[seek] == 6 do
                        array[seek] = 1
                        seek -= 1
                end
                array[seek] += 1
        end
        return array
end

def printArray(array) # reinventing the wheel, no doubt.
        print "["
        values = array * ","
        print values
        print "]"
end

def check(array,desired,hunted)
        match = hunted.to_s * desired
        return array.sort.to_s.include?(match)
end

set = Array.new(dice).fill(1)
finale = Array.new(dice).fill(6)
loop do
        $possible_count += 1
        print "#{$possible_count}. " if verbose or (sample and
$possible_count % 50000 == 1)
        printArray(set) if verbose or (sample and $possible_count % 50000 == 1)
        if check(set,desired,hunted)
                $desired_count += 1
                print " <==" if verbose or (sample and $possible_count
% 50000 == 1)
        end
        puts if verbose or (sample and $possible_count % 50000 == 1)
        break unless set != finale
        nextLogicalRoll(set)
end

puts
puts "Number of desirable outcomes is #{$desired_count}"
puts "Number of possible outcomes is #{$possible_count}"
puts
probability = $desired_count.to_f / $possible_count.to_f
puts "Probability is #{probability}"
