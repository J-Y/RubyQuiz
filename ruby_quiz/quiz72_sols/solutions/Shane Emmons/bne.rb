all_possible = ""

10.times do |key1| 10.times do |key2|
10.times do |key3| 10.times do |key4|
    current_code = Array.new
    current_code << key1 << key2 << key3 << key4
    next if all_possible =~ /#{current_code.to_s}(1|2|3)/
    left, left_over = Array.new( current_code ), Array.new
    right, right_over = Array.new( current_code ), Array.new
    while true do
        left_over << left.shift
        right_over.insert( 0, right.pop )
        if left.length == 0
            if key1 == 0
                all_possible += current_code.to_s + "1"
            elsif key1 == 1
                all_possible += current_code.to_s + "2"
            else
                all_possible += current_code.to_s + "3"
            end
            break
        elsif all_possible =~ /^#{left.to_s}(1|2|3)/
            all_possible = left_over.to_s + all_possible
            break
        elsif all_possible =~ /#{right.to_s}$/
            if key1 == 0
                all_possible += right_over.to_s + "1"
            elsif key1 == 1
                all_possible += right_over.to_s + "2"
            else
                all_possible += right_over.to_s + "3"
            end
            break
        end
    end
end end
end end

print "string length: ", all_possible.length, "\n"
