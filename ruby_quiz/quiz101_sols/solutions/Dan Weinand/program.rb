class Program
 attr_accessor :starts_at, :ends_at, :channel, :days

 # Specific programs use Time objects representing a specific date
 def specific?
   starts_at.is_a?(Time) && ends_at.is_a?(Time)
 end

 # Weekly programs use Fixnum objects representing the number of seconds from midnight
 def weekly?
   starts_at.is_a?(Fixnum) && ends_at.is_a?(Fixnum)
 end
end
