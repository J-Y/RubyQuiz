def find_knot letters     #returns first and last index which become a "knot"
letters.each_with_index do |letter1, ind1|
  (ind1+4).upto(letters.length - 1) do |ind2|
    if (ind2 - ind1) % 2 == 0
      if letters[ind2].casecmp(letter1) == 0
        return [ind1, ind2]
      end
    end
  end
end
return nil
end

def loop word
letters = word.split(//)
first, last = find_knot letters
if first.nil?
  puts "No loop"
else
  (letters.length-1).downto(last+1) { |i|
    print " "*first
    puts letters[i]
  }
  print letters[0..first+(last-first)/2-1]
  puts " "*first
  first.times {print " "}
  (last-1).downto(first+(last-first)/2) { |i| print letters[i] }
  puts
end
end

loop "Mississippi"
puts
loop "Markham"
puts
loop "Yummy"
puts
loop "Dana"
