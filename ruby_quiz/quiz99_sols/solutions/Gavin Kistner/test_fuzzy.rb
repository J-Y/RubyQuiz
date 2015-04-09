require 'test/unit'

$DEBUG = false

class Time
  def to_fuzzy
    s = strftime("%H:%M")
    s[4] = "~"
    s
  end
  def short
    strftime("%H:%M")
  end
  def round_to( seconds )
    seconds = seconds.round
    Time.at( self.to_i / seconds * seconds )
  end
end

RUNS_PER_SET = 1
class FuzzyTimeTester < Test::Unit::TestCase
  def test_running
    [ 2, 6, 17, 30, 47, 60, 65, 120, 290 ].each{ |advance_seconds|
      runs, num_ahead, num_behind = 0, 0, 0
      offsets = Hash.new(0)

      RUNS_PER_SET.times{
        t = Time.at( Time.new + rand( 3600 * 300 ) )
        end_time = t + 60 * 60 * 24 # Run for 24 hours
        ft = FuzzyTime.new( t )
        last_value = nil
        while( t < end_time )
          assert_equal t, ft.actual
          t0 = Time.at( t - 60 * 5 )
          t2 = Time.at( t + 60 * 5 )
          legal_values = [ t0, t, t2 ].map{ |x| x.to_fuzzy }.uniq

          fuzzy_fuzz = ft.to_s      

          if last_value
            y,mon,day = t.year, t.mon, t.day
            h,m = last_value.scan(/\d+/).map{ |s| s.to_i }
            m *= 10
            if (m -= 10) < 0
              m %= 60
              if (h -= 1) < 0
                h %= 24
              end
            end
            illegal_old_value = Time.local( y,mon,day,h,m ).to_fuzzy
            legal_values -= [ illegal_old_value ]
            if $DEBUG
              puts "Now: %s=>%s; legal: %s (was %s, can't be %s)" % [
                t.short, fuzzy_fuzz,
                legal_values.inspect, last_value,
                illegal_old_value
              ]
            end
          end

          assert_block( ( "It is %s, the clock displayed %s,\n" +
                        "but it should only display one of %s.\n" +
                        "(Last time I asked, it said it was %s.)" ) % [
            t.short, fuzzy_fuzz.inspect,
            legal_values.inspect,
            last_value
          ] ){
            legal_values.include?( fuzzy_fuzz )
          }

          actual_fuzz = t.to_fuzzy
          ahour, amin = actual_fuzz.scan( /\d+/ ).map{ |x| x.to_i }
          fhour, fmin = fuzzy_fuzz.scan( /\d+/ ).map{ |x| x.to_i }
          if fuzzy_fuzz != actual_fuzz
            if fmin>amin || fhour>ahour || ( fhour==0 && ahour==23 )
              num_ahead += 1
            else
              num_behind +=1
            end
          end

          if fuzzy_fuzz != last_value
            ahour2, amin2 = t.short.scan( /\d+/ ).map{ |x| x.to_i }
            if fmin>amin || fhour>ahour || ( fhour==0 && ahour==23 )
              offset = ( fmin*10 - amin2 ) % 60
            else
              offset = ( fmin*10 - amin2 )
            end
            offset = [-5, [ 5, offset ].min ].max
            offsets[ offset ] += 1
            if $DEBUG
              puts ( "It is %s, I just switched from %s to %s, " + 
                     "and I think that's an offset of %+d" ) % [
                t.short, last_value, fuzzy_fuzz, offset
              ]
            end
          end
          runs += 1      
          last_value = fuzzy_fuzz
          ft.advance( advance_seconds )
          t += advance_seconds
        end
      }

      puts "%d second advance: %.1f%% behind, %.1f%% ahead" % [
        advance_seconds,
        100.0 * num_behind / runs,
        100.0 * num_ahead / runs
      ]
      total_offsets = offsets.inject(0){ |sum,kv| sum+kv[1] }
      -5.upto(5){ |o|
        print "#{o>0?'+':''}#{o}".center( 5 )
      }; print "\n"
      -5.upto(5){ |o|
        pct = 100.0 * offsets[o] / total_offsets
        print( ( "%.#{(pct<10&&pct>0)?1:0}f%" % pct ).center( 5 ) )
      }; puts "\n "
    }
  end
end
