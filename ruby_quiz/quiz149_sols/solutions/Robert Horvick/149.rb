# Ruby Quiz 149
# Robert Horvick (robert dot horvick at gmail dot com)
# http://www.ghostonthird.com

class Array
    # [1, 3, 9] => [[1,1] [1,3] [1,9] [3,3] [3,9] [9,9]]
    def group2
        ret = []
        each_index { |i| slice(i, length).each { |x| ret << [at(i), x] } }
        ret
    end
end


class WordLoop	
    def initialize(word)
        @word = word.downcase.scan(/./m)
    end

    def print		
        # no loops for strings less than 5 chars long
        if @word.length > 4
            h = {}
            
            # build the char index groups
            @word.each_index { |i| c = @word[i]
                if h[c].nil?: h[c] = Array.new end
                h[c] << i
            }
            
            loops = []
            # find each matching pair that is 4 or more long and even length
            h.each { |k,v| loops += v.group2.delete_if {|a| 
            	a[1] - a[0] < 4 || (a[1] - a[0] & 1 == 1) } 
            }

            # print the graphs			
            if !loops.empty? then										
                loops.each { |a|
                    # print topper
                    (@word.length-1).downto(a[1]+1) { |i| 
                    	puts " " * (a[0]) + @word[i] 
                    }
                    
                    #print leader, the loop and the next
                    puts @word[0, a[0]+2].join
                    
                    # print the legs
                    leg_start = a[0]+2
                    leg_stop  = a[1]-1
                    
                    while leg_start < leg_stop
                        puts " " * a[0] + @word[leg_stop] + @word[leg_start]
                        leg_stop -= 1
                        leg_start += 1
                    end
                    
                    puts ""
                }
            else
                puts "No loop."
            end
        else
            puts "No loop."
        end
    end	
end

ARGV.each { |arg| WordLoop.new(arg).print }

