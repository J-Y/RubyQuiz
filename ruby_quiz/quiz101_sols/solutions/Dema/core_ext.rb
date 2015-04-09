class Numeric
  # Number of seconds since midnight
  def hours
    (self * 60).minutes
  end

  def minutes
    self * 60
  end

  def seconds
    self
  end

  alias_method :hour, :hours
  alias_method :minute, :minutes
  alias_method :second, :seconds
end

class Time
  def secs
    self.hour * 3600 + self.min * 60 + self.sec
  end
end
