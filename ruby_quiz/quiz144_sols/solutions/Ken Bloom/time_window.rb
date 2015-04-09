#!/usr/bin/env ruby

class TimeWindow
  DAYNAMES=%w[Sun Mon Tue Wed Thu Fri Sat]
  DAYNAME=%r{Sun|Mon|Tue|Wed|Thu|Fri|Sat}
  TIME=%r{[0-9]+}

  def initialize string
    string = " " if string == "" #make an empty string match everythingworking around the way clauses are split
    #splitting an empty string gives an empty array (i.e. no clauses)
    #splitting a " " gives a single clause with no day names (so all are used) and no times (so all are used)
    @myarray=Array.new(7){[]}

    #different clauses are split by semicolons
    string.split(/\s*;\s*/).each do |clause|

      #find the days that this clause applies to
      curdays=[]
      clause.scan(/(#{DAYNAME})(?:(?=\s)|$)|(#{DAYNAME})-(#{DAYNAME})/) do |single,start,finish|
        single &&= DAYNAMES.index(single)
        start &&= DAYNAMES.index(start)
        finish &&= DAYNAMES.index(finish)
        curdays << single if single
        if start and finish
          (start..finish).each{|x| curdays << x} if start<finish
          (start..6).each{|x| curdays << x} if finish<start
          (0..finish).each{|x| curdays << x} if finish<start
        end
      end

      #all days if no day names were given
      curdays=(0..6).to_a if curdays==[]


      #find the times that this clause applies to
      found=false
      clause.scan(/(#{TIME})-(#{TIME})/) do |start,finish|
        found=true
        curdays.each do |day|
          @myarray[day] << [start,finish]
        end
      end

      #all times if none were given
      if not found
        curdays.each {|day| @myarray[day] << ["0000","2400"]}
      end
    end
  end

  def include? time
    matchday=time.wday
    matchtime="%02d%02d" % [time.hour,time.min]
    @myarray[matchday].any?{|start,finish| start<=matchtime && matchtime<finish}
  end

  alias_method :===, :include?

end
