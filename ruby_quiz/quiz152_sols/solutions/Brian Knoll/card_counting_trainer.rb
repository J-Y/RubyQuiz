#knock-out ruby quiz
#
#thanks to steve bristol, jacksonville, fl ruby programmer, of lesseverything.com for suggestion 
#
#known issue: 3 card display doesn't  work - missing an end somewhere, I think
#
#known SciTe issue - SciTe buffers all data, even backspaces.  If you run it via SciTe, it tell you you were incorrect when you weren't. 
#   happens if you enter an answer and then change it before hitting enter
#  
##########################################

###header/version
def header
    puts "Knock-Out BlackJack Card Counting trainer v0.1"
  puts ""
end


header
card_number=0  #for multiple card display

###set deck number/# cards displayed
puts "How many decks do you want to practice with? "
STDOUT.flush #needed to run correctly in SciTe
decks = gets.chomp!.to_i
puts "And how many cards to display at once? "
STDOUT.flush
cards_display = gets.chomp!.to_i


puts "#{decks} deck/s and #{cards_display} cards displayed it is!" 
puts ""

###setup cards/card values/initial count value
cards =%w(2 3 4 5 6 7 8 9 10 J Q K A) #array of cards
                                                                                                            # is there a way to setup the array with 
                                                                                                          #something like: %w(2..10, JQKA)? 
                                                                                                            
card_values = Hash["2", -1, "3", -1, "4", -1, "5", -1, "6", -1, "7", -1, "8", 0, "9", 0, "10", 1, "J", 1, "Q", 1,\ 
"K", 1, "A", 1] #card value hash - is there a more succint way of setting up the cards and hash values?  It seems a little repetitive
                                            #can I assign values somehow like 2..7=-1; 8,9=0; 10,JQKA=1? 
shoe = cards*4*decks 
value = 4-(4*decks)
correct = 0
shoeshuf = shoe.sort_by {rand} #shuffle the cards

quit_early_rounds = 1

###user help
puts "A quick reminder: \n2-7 = -1, \n8-9 = 0,\n10-A = +1" 
puts "\nAlso, the count STARTS at 4 minus (4 x num of decks)."
puts "(so with #{decks} deck/s, your count starts at #{value})"
puts "\nGood luck!"
puts ""
puts "You're going through #{decks} deck/s with #{cards_display} cards displayed." 
puts ""


#start timer
timestart = Time.new



if cards_display == 1
    shoeshuf.each do |c|
            #for each card in shoeshuf array...
        value += card_values.fetch(c)      #add the count value... 
        
        #progress feedback
        if quit_early_rounds*cards_display == (shoeshuf.length) 
            puts "Last one!"
            
        elsif quit_early_rounds*cards_display == ( shoeshuf.length) / 2 + 1
            puts "Halfway done!"
        
        elsif quit_early_rounds*cards_display == (shoeshuf.length) / 4 + 1
            puts "1/4 done!"
        
        elsif quit_early_rounds*cards_display == ( shoeshuf.length) * 0.75 + 1
            puts "3/4 done!"
            
        end
        
        puts  c    
        puts "Count? (x to quit)"      #user test
        STDOUT.flush 
        ans = gets.chomp!.to_s
        
    # answer handling/scoring
        if ans == value.to_s
            puts "Correct!"
            correct += 1
        elsif ans == 'x'
            timeend = Time.new
            time = timeend - timestart
            puts "Summary --"
            puts "You got #{correct} right out of #{quit_early_rounds}."
            percent = correct.to_f/quit_early_rounds.to_f 
            puts "(That's #{(percent*100).to_i}%!)"
            puts "And it took you #{time.to_i} secs to complete #{quit_early_rounds} cards."
            exit
        elsif
            puts "Incorrect. Count is #{value}." 
    end
    
    quit_early_rounds += 1
    puts ""
    

end

#calc time taken
timeend = Time.new
time = timeend - timestart

puts "Summary --"
puts "You got #{correct} right out of #{ shoeshuf.length}."
puts "(That's #{correct.to_f/shoeshuf.length.to_f}%!)"
#maybe add an evaluation statement depending on # right out of total 
#percentage might be even better

puts "And it took you #{ time.to_i} secs to complete #{decks} deck/s"
#eval ... i.e. "The goal is 30 seconds for 1 deck! You are #{second} from that goal! Keep working!"
end

######################################
# 2 card display 
if cards_display == 2
    puts "You said 2 cards to display"
    quit_early_rounds += 1
    while shoeshuf[card_number] != nil
        
        print shoeshuf[card_number] + "   "
    #acount for value? (running count?)
        value += card_values.fetch(shoeshuf[card_number])  #keep count 
        card_number +=1  # keep cards moving
        puts shoeshuf[card_number] 
    value += card_values.fetch(shoeshuf[card_number]) 
        card_number +=1
        
        #progress feedback
        if quit_early_rounds == (shoeshuf.length) 
            puts "Last one!"
            
        elsif quit_early_rounds == ( shoeshuf.length) / 2 
            puts "Halfway done!"
        
        elsif quit_early_rounds == (shoeshuf.length) / 4 + 1
            puts "1/4 done!"
        
        elsif quit_early_rounds == ( shoeshuf.length) * 0.75 + 1
            puts "3/4 done!"
            
        end
        
      puts "Running Count? (x to quit)"      #user test
        STDOUT.flush
        ans = gets.chomp!.to_s
    
    if ans == value.to_s
        puts "Correct!"
        correct += 1
    elsif ans == 'x'
        timeend = Time.new
        time = timeend - timestart
        puts "Summary --" 
    puts "You got #{correct} right out of #{quit_early_rounds}."
     percent = correct.to_f/quit_early_rounds.to_f
     puts "(That's #{(percent*100).to_i}%!)"
     puts "And it took you #{ time.to_i} secs to complete #{quit_early_rounds} cards."
        exit
    elsif
        puts "Incorrect. Count is #{value}."
    end
    
    quit_early_rounds += cards_display
    puts "" 
    
end




######################################
# 3 card display -- having trouble with this -- when you enter 3 (or anything other than 1-2) you skip out -- end issues?
if cards_display == 3 
    puts "You said 3 cards to display"
    quit_early_rounds += 1
    while shoeshuf[card_number] != nil
        
        print shoeshuf[card_number] + "   "
    #acount for value? (running count?) 
        value += card_values.fetch(shoeshuf[card_number])  #keep count 
        card_number +=1  # keep cards moving
        print shoeshuf[card_number] + "   "
    value += card_values.fetch(shoeshuf[card_number]) 
        card_number +=1
        puts shoeshuf[card_number] 
    value += card_values.fetch(shoeshuf[card_number])
        card_number +=1
        
        #progress feedback
        if quit_early_rounds == ( shoeshuf.length) 
            puts "Last one!"
            
        elsif quit_early_rounds == (shoeshuf.length) / 2 
            puts "Halfway done!"
        
        elsif quit_early_rounds == ( shoeshuf.length) / 4 + 1
            puts "1/4 done!"
        
        elsif quit_early_rounds == (shoeshuf.length) * 0.75 + 1
            puts "3/4 done!"
            
        end
            
      puts "Running Count? (x to quit)"      #user test
        STDOUT.flush
        ans = gets.chomp!.to_s
    
    if ans == value.to_s
        puts "Correct!"
        correct += 1 
    elsif ans == 'x'
        timeend = Time.new
        time = timeend - timestart
        puts "Summary --"
    puts "You got #{correct} right out of #{quit_early_rounds}."
     percent = correct.to_f/quit_early_rounds.to_f
     puts "(That's #{(percent*100).to_i}%!)"
     puts "And it took you #{time.to_i} secs to complete #{quit_early_rounds} cards."
        exit 
    elsif
        puts "Incorrect. Count is #{value}."
    end
    
    quit_early_rounds += cards_display
    puts ""
    
end


end
end


#calc time taken 
timeend = Time.new
time = timeend - timestart

puts "Summary --"
puts "You got #{correct} right out of #{shoeshuf.length}."
puts "(That's #{correct.to_f/shoeshuf.length.to_f }%!)"
#maybe add an evaluation statement depending on # right out of total 
#percentage might be even better

puts "And it took you #{time.to_i} secs to complete #{decks} deck/s"
#eval ... i.e . "The goal is 30 seconds for 1 deck! You are #{second} from that goal! Keep working!"

 #getting an error on this line? undefined method "+" for nil class, but prog runs fine
#account for value? (running count?) 
    
#need some feedback DURING the process to let you know where you are in 
#process, ESP with more than 1 decks

#when do you bet with knockout? depends on the number of decks
#    
