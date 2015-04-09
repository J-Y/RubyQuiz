class String
  def mangle
    if self.size < 3
      self
    else
      original = self.split(//)
      first = self[0,1]
      last = self[-1,1]
      innards_munged = self[1,(size-2)].gsub(/[^a-zA-Z]/, "").shuffle!.split(//)

      output = []

      output << first

      original.each { |l|
        if l =~ /[a-zA-Z]/
          output << innards_munged.pop
        else
          output << l
        end
      }
      output << last
      output.to_s
    end
  end

  def shuffle!
    (0...size).each { |j|
      i = rand(size-j)
      self[j], self[j+i] = self[j+i], self[j]
    }
    self
  end

  def munge
    words = self.split(/\b/)
    output = []
    words.each { |w|
      output << w.mangle
    }
    output.to_s
  end
end
