require 'test/unit'
require 'FuzzyTime.rb'

class FuzzyTimeTest < Test::Unit::TestCase
   
    def setup
        @epoch = Time.at(0)#Wed Dec 31 19:00:00 CST 1969
    end
    
    def test_advance
        ft = FuzzyTime.new(@epoch)#set time to epoch
        assert_equal(@epoch, ft.time)
        increment = 60 * 10
        ft.advance(increment) #move ahead 
        assert_not_equal(@epoch, ft.time)
        assert_equal(@epoch + increment, ft.time)
    end
    
    def test_update
        ft = FuzzyTime.new(@epoch)#set time to epoch
        assert_equal(@epoch, ft.time)
        assert_not_equal(@epoch, ft.update)
        assert_not_equal(@epoch, ft.time)
    end    
    
    def test_to_s
        ft = FuzzyTime.new(@epoch)#set time to epoch
        assert_match(/0[6|7]:[5|0]~/, ft.to_s)
        ft.advance(60*5)#07:05
        assert_match(/07:[0|1]~/, ft.to_s)
        ft.advance(60*10)#07:15
        assert_match(/07:[1|2]~/, ft.to_s)
        ft.advance(60*12)#07:27
        assert_match(/07:[2|3ƒ]~/, ft.to_s)
        
    end
    
    def test_random_time
        ft = FuzzyTime.new(@epoch) #set time to epoch        
        
        #it always reduce the time
        def ft.subtract_time?
            puts "override subtract"
            true 
        end
        #not so random. make it return 10 minutes
        def ft.random(seconds)
            puts "override random"
            return 1
        end
        
        previous_fuzzy_time = @epoch+60
        result = ft.random_time(@epoch, previous_fuzzy_time)
        assert(ft.fuzzy_compare(result, previous_fuzzy_time) > -1)
        
        previous_fuzzy_time = @epoch+(60*50)
        result = ft.random_time(previous_fuzzy_time, previous_fuzzy_time)
        assert(ft.fuzzy_compare(result, previous_fuzzy_time) > -1)
    end
    
    def test_fuzzy_compare
        ft = FuzzyTime.new
        dec_2005 = Time.gm(2005, "dec", 31, 23, 59, 59)
        jan_2006 = Time.gm(2006, "jan", 01, 01, 00, 00)
        assert_equal(-1, ft.fuzzy_compare(dec_2005, jan_2006))
        assert_equal(0, ft.fuzzy_compare(dec_2005, dec_2005))
        assert_equal(0, ft.fuzzy_compare(jan_2006, jan_2006))
        assert_equal(1, ft.fuzzy_compare(jan_2006, dec_2005))
        
        fuzzy_jan_2006 = Time.gm(2006, "jan", 01, 01, 9, 59)
        assert_equal(0, ft.fuzzy_compare(jan_2006, fuzzy_jan_2006))
    end
     
    def test_output_advance
        ft = FuzzyTime.new(@epoch)
        ft.to_s
        240.times do
            
            prev_fuzzy_time = Time.at(ft.fuzzy_time.to_i)#get the previously printed time value
            ft.advance(60)#advance clock 1 minute
            ft.to_s
            curr_fuzzy_time = ft.fuzzy_time
            
            #req#3: the prev hour should always be <= current hour
            assert(prev_fuzzy_time.hour <= curr_fuzzy_time.hour)
            
            #req#3: if the hour is the same, then the 
            #prev_minute-curr_minute <=10    
            if(prev_fuzzy_time.hour == curr_fuzzy_time.hour && 
                ((curr_fuzzy_time.min / 10).floor <  (prev_fuzzy_time.min / 10).floor))
                current = curr_fuzzy_time.strftime("%I:%M")
                previous = prev_fuzzy_time.strftime("%I:%M")
                fail("Current Time:#{current} cannot be < than Previous Time: #{previous}")
            end
            
            #The difference between the current minutes and previoues minutes cannot
            #be greater than 10
            if(prev_fuzzy_time.hour == curr_fuzzy_time.hour) 
                diff = curr_fuzzy_time.min - prev_fuzzy_time.min
                assert(diff >= -10)
                assert(diff <= 10)
            end
        end    
    end
    
    def test_output_update
        ft = FuzzyTime.new(@epoch)
        ft.to_s
        240.times do
            
            prev_fuzzy_time = Time.at(ft.fuzzy_time.to_i)#get the previously printed time value
            ft.update
            ft.to_s
            curr_fuzzy_time = ft.fuzzy_time
            
            #req#3: the prev hour should always be <= current hour
            assert(prev_fuzzy_time.hour <= curr_fuzzy_time.hour)
            
            #req#3: if the hour is the same, then the 
            #prev_minute-curr_minute <=10    
            if(prev_fuzzy_time.hour == curr_fuzzy_time.hour && 
                ((curr_fuzzy_time.min / 10).floor <  (prev_fuzzy_time.min / 10).floor))
                current = curr_fuzzy_time.strftime("%I:%M")
                previous = prev_fuzzy_time.strftime("%I:%M")
                fail("Current Time:#{current} cannot be < than Previous Time: #{previous}")
            end
            
            #The difference between the current minutes and previoues minutes cannot
            #be greater than 10
            if(prev_fuzzy_time.hour == curr_fuzzy_time.hour) 
                diff = curr_fuzzy_time.min - prev_fuzzy_time.min
                assert(diff >= -10)
                assert(diff <= 10)
            end
        end    
    end    
end


