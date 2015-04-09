require 'abbrev'
require 'test/unit'

class DayRange

  def self.use_day_names(week, abbrev_length=3)
    @day_numbers = {}
    @day_abbrevs = {}
    week.abbrev.each do |abbr, day|
      num = week.index(day) + 1
      @day_numbers[abbr] = num
      if abbr.length == abbrev_length
        @day_abbrevs[num] = abbr
      end
    end
  end

  use_day_names \
    %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

  def day_numbers; self.class.class_eval{ @day_numbers } end
  def day_abbrevs; self.class.class_eval{ @day_abbrevs } end

  attr_reader :days

  def initialize(days)
    @days = days.collect{ |d| day_numbers[d] or d }
    if not (@days - day_abbrevs.keys).empty?
      raise ArgumentError
    end
  end

  def to_s
    ranges = []
    number_ranges.each do |range|
      case range[1] - range[0]
      when 0; ranges << day_abbrevs[range[0]]
      when 1; ranges.concat day_abbrevs.values_at(*range)
      else    ranges << day_abbrevs.values_at(*range).join('-')
      end
    end
    ranges.join(', ')
  end

  def number_ranges
    @days.inject([]) do |l, d|
      if l.last and l.last[1] + 1 == d
        l.last[1] = d
      else
        l << [d, d]
      end
      l
    end
  end

end

class DayRangeGerman < DayRange
  use_day_names \
    %w(Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag), 2
end


class DayRangeTest < Test::Unit::TestCase

  def test_english
    tests = {
      [1,2,3,4,5,6,7] => 'Mon-Sun',
      [1,2,3,6,7]     => 'Mon-Wed, Sat, Sun',
      [1,3,4,5,6]     => 'Mon, Wed-Sat',
      [2,3,4,6,7]     => 'Tue-Thu, Sat, Sun',
      [1,3,4,6,7]     => 'Mon, Wed, Thu, Sat, Sun',
      [7]             => 'Sun',
      [1,7]           => 'Mon, Sun',
      %w(Mon Tue Wed) => 'Mon-Wed',
      %w(Frid Saturd Sund) => 'Fri-Sun',
      %w(Monday Wednesday Thursday Friday) => 'Mon, Wed-Fri',
      [1, 'Tuesday', 3] => 'Mon-Wed'
    }
    tests.each do |days, expected|
      assert_equal expected, DayRange.new(days).to_s
    end
  end

  def test_german
    tests = {
      [1,2,3,4,5,6,7] => 'Mo-So',
      [1,2,3,6,7]     => 'Mo-Mi, Sa, So',
      [1,3,4,5,6]     => 'Mo, Mi-Sa',
      [2,3,4,6,7]     => 'Di-Do, Sa, So',
      [1,3,4,6,7]     => 'Mo, Mi, Do, Sa, So',
      [7]             => 'So',
      [1,7]           => 'Mo, So',
      %w(Mo Di Mi)    => 'Mo-Mi',
      %w(Freit Samst Sonnt) => 'Fr-So',
      %w(Montag Mittwoch Donnerstag Freitag) => 'Mo, Mi-Fr',
      [1, 'Dienstag', 3] => 'Mo-Mi'
    }
    tests.each do |days, expected|
      assert_equal expected, DayRangeGerman.new(days).to_s
    end
  end

  def test_translation
    eng = %w(Mon Tue Wed Fri)
    assert_equal 'Mo-Mi, Fr',
                 DayRangeGerman.new(DayRange.new(eng).days).to_s
  end

  def test_should_raise
    assert_raise ArgumentError do
      DayRange.new([1, 8])
    end
  end

end
