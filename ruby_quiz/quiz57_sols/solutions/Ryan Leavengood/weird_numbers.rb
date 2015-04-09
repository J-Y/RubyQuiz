class Array
  def sum
    inject(0) do |result, i|
      result + i
    end
  end
end

class Integer
  def weird?
    # No odd numbers are weird within reasonable limits.
    return false if self % 2 == 1
    # A weird number is abundant but not semi-perfect.
    divisors = calc_divisors
    abundance = divisors.sum - 2 * self
    # First make sure the number is abundant.
    if abundance > 0
      # Now see if the number is semi-perfect. If it is, it isn't weird.
      # First thing see if the abundance is in the divisors.
      if divisors.include?(abundance)
        false
      else
        # Now see if any combination sums of divisors yields the abundance.
        # We reject any divisors greater than the abundance and reverse the
        # result to try and get sums close to the abundance sooner.
        to_search = divisors.reject{|i| i > abundance}.reverse
        sum = to_search.sum
        if sum == abundance
          false
        elsif sum < abundance
          true
        else
          not abundance.sum_in_subset?(to_search)
        end
      end
    else
      false
    end
  end

  def calc_divisors
    res=[1]
    2.upto(Math.sqrt(self).floor) do |i|
      if self % i == 0
        res << i
      end
    end
    res.reverse.each do |i|
      res << self / i
    end
    res.uniq
  end

  def sum_in_subset?(a)
    if self < 0
      false
    elsif a.include?(self)
      true
    else
      if a.length == 1
        false
      else
        f = a.first
        remaining = a[1..-1]
        (self - f).sum_in_subset?(remaining) or sum_in_subset?(remaining)
      end
    end
  end
end

class WeirdCache
  def initialize(filename='.weirdcache')
    @filename = filename
    if test(?e, filename)
      @numbers = IO.readlines(filename).map do |i|
        i.chomp.to_i
      end
    else
      @numbers=[]
    end
    @added = false
  end

  def each(&block)
    @numbers.each(&block)
  end

  def <<(i)
    @added = true
    @numbers << i
  end

  def save
    if @added
      File.open(@filename, File::RDWR|File::CREAT|File::TRUNC) do |file|
        file.puts @numbers
      end
    end
  end
end

if $0 == __FILE__
  if ARGV.length < 1
    puts "Usage: #$0 <upper limit>"
    exit(1)
  end

  puts "Weird numbers up to and including #{ARGV[0]}:"
  start = Time.now
  cache = WeirdCache.new
  at_exit {cache.save}
  limit = ARGV[0].to_i
  i = 69
  cache.each do |i|
    if i <= limit
      puts i
    end
  end
  (i+1).upto(limit) do |j|
    if j.weird?
      cache << j
      puts j
    end
  end
  puts "This took #{Time.now - start} seconds"
end
