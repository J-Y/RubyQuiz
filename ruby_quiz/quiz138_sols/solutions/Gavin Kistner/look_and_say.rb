class Integer
  def each_digit
    to_s.each_byte{ |b| yield( b - ?0 ) }
  end
  def look_and_say
    digits, counts = [], []
    each_digit{ |d|
     if digits.last == d
       counts[ counts.size - 1 ] += 1
      else
        digits << d
        counts << 1
      end
    }
    counts.zip( digits ).join.to_i
  end
end

n = 1
12.times{ p n; n = n.look_and_say }
