class DayRange

  def initialize(*days)
    @@i_to_d ||= %w(Baz Mon Tue Wed Thu Fri Sat Sun)
    @@d_to_i ||= Hash.new{ |h,k| raise( ArgumentError, "\"#{k}\" is not a valid date key." ) }
    if @@d_to_i.empty?
      @@d_to_i.merge!( {
        'monday' => 1, 'mon' => 1, '1' => 1,
	'tuesday' => 2, 'tue' => 2, '2' => 2,
        'wednesday' => 3, 'wed' => 3, '3' => 3,
        'thursday' => 4, 'thu' => 4, '4' => 4,
        'friday' => 5, 'fri' => 5, '5' => 5,
	'saturday' => 6, 'sat' => 6, '6' => 6,
        'sunday' => 7, 'sun' => 7, '7' => 7
      } )
    end
    set_days(days)
  end

  def set_days(d)
    return self if d.nil? || !d.respond_to?( :each )
    @days = []
    d.each { |day| @days << @@d_to_i[day.to_s.downcase] }
    @days = @days.uniq.sort
    glob_it
    self
  end

  alias :set_days! :set_days

  def to_s
    @globbed
  end

  def glob_it
    if @days.empty?
      @globbed = 'none'
      return
    end
    
    sa = []
    i = 0
    while i < @days.length do
      s = e = @days[i]
      i += 1
      while ( @days[i] && @days[i] == e + 1 )
	e = @days[i]
	i += 1
      end
      case (e - s)
      when 0
	sa << @@i_to_d[s]
      when 1
	sa << @@i_to_d[s] << @@i_to_d[e]
      else
        sa << @@i_to_d[s] + "-" + @@i_to_d[e]
      end
    end
    @globbed = sa.join(", ")
  end

end

if __FILE__ == $0
  require 'test/unit'
  class DayRangeTester < Test::Unit::TestCase
    def test_day_range()

      d1 = DayRange.new( 1, 2, 'Wednesday', 'Fri', 'sat' )
      assert_equal( d1.to_s, "Mon-Wed, Fri, Sat" )

      d1.set_days( ["moNday", "MON", "1", "mon", 1, 1] )
      assert_equal( d1.to_s, "Mon" )

      d2 = DayRange.new( 7, 6, 5, 3, 2, 1 )
      assert_equal( d2.to_s, "Mon-Wed, Fri-Sun" )

      d1.set_days!( [2, 2, 3, 5, 6, 1, 7, 2] )
      assert_equal( d1.to_s, d2.to_s )

      assert_raise( ArgumentError ) { DayRange.new( "Sunday", "Moonday" ) }

      assert_raise( ArgumentError ) { d2.set_days( [8] ) }
      
      assert_equal( DayRange.new().to_s, "none" )

      assert_equal( DayRange.new( 1, 2, 3, 4, 5, 6, 7 ).to_s, "Mon-Sun" )

    end
  end
end
