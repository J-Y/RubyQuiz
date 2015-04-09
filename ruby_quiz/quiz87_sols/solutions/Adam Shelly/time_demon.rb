# time_demon.rb
# (only tested on windows)

module Time_Demon
 if RUBY_PLATFORM =~ /(win|w)32$/
   TimeStrFormat = "time %H:%M:%S"
 else
   TimeStrFormat = "date -s %H:%M:%S"
 end

 def sleep sec
   t = Time.now
   t+=sec
   system(t.strftime(TimeStrFormat))
   sec.to_i
 end
end

if __FILE__ == $0
p "the time is #{Time.now}"
sleep 5
p "the time is #{Time.now}"
begin
sleep -5
rescue Exception => ex
 p "caught >>#{ex}<<"
end
p "the time is #{Time.now}"

include Time_Demon
sleep 100
p "the time is #{Time.now}"
sleep -50
p "the time is #{Time.now}"
sleep -50
p "the time is #{Time.now}"
end
