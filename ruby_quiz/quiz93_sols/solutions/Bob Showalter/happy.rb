class Integer

  # cache of happy true/false by number
  @@happy = Hash.new

  # sum of squares of digits
  def sosqod
    sum = 0
    self.to_s.each_byte { |d| d -= ?0; sum += d * d }
    sum
  end

  # am I a happy number?
  def happy?
    return true if self == 1
    return @@happy[self] if @@happy.include?(self)
    @@happy[self] = false
    @@happy[self] = self.sosqod.happy?
  end

end

