#!/usr/bin/env ruby
WHEELBASE_AVG    = 100    # inches
INCHES_PER_MILE  = 63_360
SECONDS_PER_HOUR = 3600.0
INCHES_PER_SECOND_TO_MPH = 17.6

USAGE = <<ENDUSAGE
Usage:
   vehicle_counter [-t time_segment] [-a] data_file
   -t,--time     the number of minutes per segment (defaults to 60)
   -a,--average  average time samples across days
                 (defaults to showing each day indpendently)
ENDUSAGE

ARGS = {
  :time_segment => 60,
  #:data_file    => 'vehicle_counter.data'
}
UNFLAGGED_ARGS = [ :data_file ]
next_arg = UNFLAGGED_ARGS.first
ARGV.each{ |arg|
   case arg
     when '-t','--time'
       next_arg = :time_segment
     when '-a','--average'
       ARGS[:average] = true
     else
       if next_arg
         if next_arg==:time_segment
           arg = arg.to_i
         end
         ARGS[next_arg] = arg
         UNFLAGGED_ARGS.delete( next_arg )
       end
       next_arg = UNFLAGGED_ARGS.first
   end
}

if !ARGS[:data_file] || !ARGS[:time_segment]
   puts USAGE
   exit
end

class Record
  SECONDS_PER_DAY = 3600 * 24
  attr_reader :time, :direction, :ms
  attr_accessor :speed
  def initialize( str, day_offset )
    _, @direction, @ms = /([AB])(\d+)/.match( str ).to_a
    @ms = @ms.to_i
    @time = Time.gm( 2007 ) + ( @ms.to_i / 1000.0 ) + ( day_offset * SECONDS_PER_DAY )
  end
end


# Prepare data
raw_data = IO.readlines( ARGS[:data_file] )
day_changes = 0
records = raw_data.inject([]){ |records,line|
  record = Record.new( line, ARGS[:average] ? 0 : day_changes )
  if (last_record = records.last) && (record.ms < last_record.ms)
    day_changes += 1
  end
  records << record
}

# Convert axle pairs to speed
last_record = {}
records.each{ |record|
  if last_axle = last_record[ record.direction ]
    last_axle.speed  = WHEELBASE_AVG / ( record.time - last_axle.time )
    last_axle.speed /= INCHES_PER_SECOND_TO_MPH
    last_record[ record.direction ] = nil
  else
    last_record[ record.direction ] = record
  end
}
records.delete_if{ |r| r.speed.nil? }

# Figure out which direction gets double hits
possible_directions  = records.map{ |r| r.direction }.uniq
double_hit_direction = possible_directions.map{ |dir|
  [ records.select{ |r| r.direction == dir }.length , dir ]
}.sort.last.last

# Remove extraneous records
require 'enumerator'
records.each_cons(2){ |r1,r2|
  if (r1.direction == double_hit_direction) &&
     (r2.direction != double_hit_direction) &&
     # 0.02 seconds @ 50mph is ~18 inches
     # If the times are this close, it must be a double hit
     (r1.time - r2.time).abs < 0.02
    r1.speed = nil
  end
}
records.delete_if{ |r| r.speed.nil? }

t1 = Time.gm(0)
ms_trigger = 0
slot_count = nil
ms_per_slot = ARGS[ :time_segment ] * 60 * 1000
records << Record.new( 'B99999999', 0 )
records.each{ |r|
  if r.ms >= ms_trigger
    if slot_count
      t2 = t1 + ms_per_slot / 1000.0
      print "#{t1.strftime('%H:%M')}..#{t2.strftime('%H:%M')} : "
      puts "%4i %s, %4i %s" % possible_directions.map{ |dir|
        [slot_count[dir],dir=="A" ? "left" : "right"]
      }.flatten
      t1 = t2
    end
    slot_count = Hash[ *possible_directions.map{ |d| [d,0] }.flatten ]
    ms_trigger += ms_per_slot
  end
  slot_count[ r.direction ] += 1
}
