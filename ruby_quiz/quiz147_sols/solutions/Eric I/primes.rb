# Generates a stream of prime numbers as they're read from a sequence
# of files with names such as "primes1.txt", "primes2.txt", and so
# forth.  Such files can be downloaded from:
#   http://primes.utm.edu/lists/small/millions/


class Prime
  def initialize
    @current_file = 0
    @io = open_next_file
    @current_primes = []
    @current_index = 0
  end

  def next
    load_next_primes until value = @current_primes[@current_index]
    @current_index += 1
    value
  end

  private

  def load_next_primes
    while true
      while line = @io.gets
        if line =~ /^\s*\d+(\s+\d+)*\s*$/
          @current_primes = line.split.map { |e| e.to_i }
          @current_index = 0
          return
        end
      end
      @io.close
      open_next_file
    end
  end

  def open_next_file
    @current_file += 1
    filename = "primes%d.txt" % @current_file
    begin
      @io = open(filename)
    rescue
      raise "ran out of primes because couldn't open file \"%s\"" %
        filename
    end
  end
end
