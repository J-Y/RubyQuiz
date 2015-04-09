#! /usr/bin/env ruby

require 'enumerator'
require 'facet/symbol/to_proc'

class DaySet
  class Day
    include Comparable

    # Convenience conversion routines
    class ::String; def to_day; Day.new(self); end; end
    class ::Integer; def to_day; Day.new(self); end; end

    # Hash providing basic day name <=> day number mapping
    names = %w{ Monday Tuesday Wednesday Thursday Friday Saturday Sunday }
    MAPPING = names.enum_with_index.inject({}) do |hash, name_idx|
      name, idx = name_idx[0], name_idx[1] + 1
      hash.update idx => name[0, 3], \
        name[0, 3].downcase => idx, name.downcase => idx
    end

    def self.new(arg)
      # Implement the flyweight pattern by replacing Day.new
      day = arg.to_i > 0 ? arg.to_i : MAPPING[arg.to_s.downcase] rescue nil
      unless day and day >= 1 and day <= 7
        raise ArgumentError, "invalid day `%s'" % arg
      end

      # There are only seven days, so we only create seven objects
      @day_pool ||= {}
      @day_pool[day] ||= super(day)
    end
    
    def initialize(arg)
      # All the heavy lifting is in Day.new
      @day = arg
    end

    def to_day; self; end
    def to_i; @day; end
    def to_s; MAPPING[@day].dup; end
    def inspect; "#<" << to_s << ">"; end
    
    def +(other)
      # Day arithmetic is mod 7 to allow #<Sun> + 1, etc
      Day.new(((to_i + other - 1) % 7) + 1)
    end

    def -(other)
      Day.new(((to_i - other - 1) % 7) + 1)
    end
    
    def <=>(other)
      @day <=> other.to_day.to_i rescue nil
    end

    def succ
      # Allows the creation of Ranges of Days
      Day.new((to_i % 7) + 1)
    end
    alias :next :succ
  end
end

class DaySet
  def initialize(*days)
    # Accept any combination of arrays and raw arguments
    @days = days.flatten.collect do |day|
      # Accept multiple days in a single string
      day.split(/, */) rescue day
    end.flatten.collect do |day|
      # Accept day ranges within a string
      Range.new(*day.split('-').collect(&:to_day)).to_a rescue day
    end.flatten.collect do |day|
      Day.new(day)
    end.sort!.uniq
  end

  def to_a; @days.dup; end

  def to_s
    @days.inject([]) do |sum, day|
      # Assemble (first, last) pairs of each contiguous sequence of days
      first, last = sum.last
      if last and last == day - 1
        sum.last[1] = day
        sum
      else
        sum << [ day, day ]
      end
    end.collect do |first, last|
      # Transform the pairs into strings as specified by the Quiz
      case
      when first == last;     "#{first}"
      when first == last - 1; "#{first}, #{last}"
      else;                   "#{first}-#{last}"
      end
    end.join(", ") # And merge the strings together
  end

  def inspect; "#<" << to_s << ">"; end
  
  def add(day)
    # Allow new days to be added
    @days.push(Day.new(day)).sort!.uniq!
    self
  end
  alias :<< :add
  
  def delete(day)
    # And allow days to be removed
    @days.delete(day)
  end
  alias :remove :delete
end


if $0 == __FILE__
  require 'test/unit'

  class DaySetTest < Test::Unit::TestCase
    cases =
      [ [1,2,3,4,5,6,7],    "Mon-Sun",
        [1,2,3,6,7],        "Mon-Wed, Sat, Sun",
        [1,3,4,5,6],        "Mon, Wed-Sat",
        [2,3,4,6,7],        "Tue-Thu, Sat, Sun",
        [1,3,4,6,7],        "Mon, Wed, Thu, Sat, Sun",
        [7],                "Sun",
        [1,7],              "Mon, Sun",
        [1,8],              ArgumentError,
        ["Mon, Tue"],       "Mon, Tue",
        ["Mon, Thu-Sat"],   "Mon, Thu-Sat",
        ["Tue", "Thu-Sun"], "Tue, Thu-Sun",
        ["Monday, Sunday"], "Mon, Sun",
        ["Fooday"],         ArgumentError,
      ]

    cases.enum_slice(2).each_with_index do |pair, index|
      args, result = pair
      mname = "test_#{index}".to_sym
      
      if result.is_a? Class
        define_method mname do
          assert_raise result do
            DaySet.new *args
          end
        end
        
      else
        define_method mname do
          assert_equal result, DaySet.new(*args).to_s
        end
        
      end
    end

    def test_left_shift
      assert_equal "Tue-Thu", (DaySet.new(2,4) << "Wed").to_s
      assert_equal "Tue, Wed", (DaySet.new(2,3) << "Wed").to_s
    end
  end
end
