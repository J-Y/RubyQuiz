################################################
# fuzzy_time_test.rb

require 'test/unit'
require 'fuzzy_time'

class FuzzyTime_Test < Test::Unit::TestCase
 #def setup
 #end

 #def teardown
 #end

 def test_advance

   # Initialize with a known UTC time (Tue Jun 10 03:14:52 UTC 1975)
   ft = FuzzyTime.new(Time.at(171602092).getgm, 60, 60, "%H:%M:%S")

   # Add 6 hours 45 minutes 30 secs to give us
   # (Tue Jun 10 09:59:22 UTC 1975)
   ft.advance(3600*6 + 60*45 + 30)
   @last_output = ""

   60.times do
     # Initial displayed time sourced from between 09:58:52 and 09:59:52
     # Time will be advanced by between 0 and 600 seconds.
     # So final displayed time source ranges from 10:08:52 to 10:09:52

     # The array of legal output strings:
     @legal  = ["09:58:~~", "09:59:~~", "10:00:~~", "10:01:~~",
       "10:02:~~", "10:03:~~", "10:04:~~", "10:05:~~",
       "10:06:~~", "10:07:~~", "10:08:~~", "10:09:~~"]

     @output = ft.to_s

     assert_block "#@output not one of #{@legal.inspect}" do
       @legal.include?( @output )
     end

     assert_block  "#@output must be greater than or equal to " \
       "last value, #@last_output" \
     do
       @output >= @last_output
     end
     @last_output = @output

     ft.advance( rand( 11 ) )
   end
 end

 def test_advance_rollover
   # Initialize with a known UTC time (Fri Dec 31 23:58:25 UTC 1999)
   # Test rollover at midnight
   # Note, we have an accuracy of +/- 5 secs now and enabled the
   # observations timer
   ft = FuzzyTime.new(Time.at(946684705).getgm, 10, 10, "%H:%M:%S", 10)

   30.times do
     # Initial displayed time sourced from between 23:58:20 and 23:58:30
     # Time will be advanced by between 0 and 150 seconds.
     # So final displayed time source ranges from 00:00:50 to 00:01:00

     # Note, if we watch too often over a short period of time,
     # our displayed accuracy will decrease.  Then we will lose
     # the 10's digit of the seconds and occasionally the 1's minute.

     # The array of legal output strings:
     @legal = ["23:58:1~", "23:58:2~", "23:58:3~",
       "23:58:4~", "23:58:5~", "23:58:6~",
       "23:58:~~", "23:59:~~", "23:5~:~~",
       "23:59:0~", "23:59:1~", "23:59:2~",
       "23:59:3~", "23:59:4~", "23:59:5~",
       "00:00:0~", "00:00:1~", "00:00:2~",
       "00:00:3~", "00:00:4~", "00:00:5~", "00:00:~~",
       "00:01:0~", "00:01:~~", "00:0~:~~"]

     @output = ft.to_s

     assert_block "#@output not one of #{@legal.inspect}" do
       @legal.include?( @output )
     end

     # We cannot easily check that the current output is greater or equal to
     # the last because with timed observations, a valid output sequence is:
     # 23:59:0~
     # 23:59:~~ (looking too often, accuracy has been reduced)
     # 23:59:0~ (waited long enough before observing for accuracy to return)

     ft.advance( rand(6) )
   end
 end

 def test_update
   # NOTE - this test takes 5-10 minutes to complete

   # Initialize with a known UTC time (Tue Jun 10 03:14:52 UTC 1975)
   ft = FuzzyTime.new(Time.at(171602092).getgm, 60, 60, "%H:%M:%S")
   @last_output = ""

   60.times do
     # Initial displayed time sourced from between 03:14:22 and 03:15:22
     # Duration of loop will be between 0 and ~600 seconds.
     # So final displayed time source ranges from 03:14:22 to 03:25:22

     # The array of legal output strings:
     @legal  = ["03:14:~~", "03:15:~~", "03:16:~~", "03:17:~~",
       "03:18:~~", "03:19:~~", "03:20:~~", "03:21:~~",
       "03:22:~~", "03:23:~~", "03:24:~~", "03:25:~~"]

     @output = ft.to_s

     assert_block "#@output not one of #{@legal.inspect}" do
       @legal.include?( @output )
     end

     assert_block  "#@output must be greater than or equal to " \
       "last value, #@last_output" \
     do
       @output >= @last_output
     end
     @last_output = @output

     sleep( rand( 11 ) ) # wait between 0..10 secs
     ft.update
   end
 end
end
