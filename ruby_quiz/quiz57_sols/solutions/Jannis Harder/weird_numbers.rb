=begin

References:

http://en.wikipedia.org/wiki/Divisor_function
http://en.wikipedia.org/wiki/Weird_number
Eric W. Weisstein. "Weird Number." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/WeirdNumber.html
Eric W. Weisstein. "Semiperfect Number." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/SemiperfectNumber.html
Eric W. Weisstein. "Perfect Number." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/PerfectNumber.html
Eric W. Weisstein. "Divisor Function." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/DivisorFunction.html
Eric W. Weisstein. "Mersenne Prime." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/MersennePrime.html
Eric W. Weisstein. "Abundance." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/Abundance.html

=end


class Integer
  $prime_factors = Hash.new # we cache prime factors...
  def prime_factors position = -1
    if cached = $prime_factors[self] # cached?
      return cached # yes
    end

    if self == 1 # we have 1 we are done
      return $prime_factors[self]=[] # return no factors
    elsif position<0 # we havn't reached factor 5 yet
      if self&1 == 0 # test factor 2
        return $prime_factors[self]=[2,*(self>>1).prime_factors]
      elsif self%3 == 0 # and factor 3
        return $prime_factors[self]=[3,*(self/3).prime_factors]
      end
    end

    loop do
      position+=6 # increment position by 6
      if position*position > self # we have a prime number return it
        return $prime_factors[self]=[self]
      elsif (quo,rem = divmod(position))   and rem.zero? # test 6n-1
        return $prime_factors[self]=[position,*quo.prime_factors(position-6)]
      elsif (quo,rem = divmod(position+2)) and rem.zero? # and 6n+1
        return $prime_factors[self]=[position+2,*quo.prime_factors(position-6)]
      end
    end
  end

  def distinct_prime_factors # rle encode the prime factors ;)
    distinct_prime_fac = Hash.new{0} # setup the hash
    prime_factors.each do |prime_factor| # fill it
      distinct_prime_fac[prime_factor]+=1
    end
    distinct_prime_fac.to_a.sort_by{|(fac,count)|fac} # and return it as sorted array
  end


  def divisors # get the divisors (not needed for divisor sum)
    divs = [] # store divisors here
    n = 1 # start with 1
    loop do
      break if n*n > self # done
      if (qua,rem = divmod(n)) and rem.zero? # test for division
        divs << qua # add divisors
        divs << n
      end
      n+=1
    end
    divs.uniq.sort[0..-2] # we don't want self
  end



  def semi_perfect? deficient=false # final test
    cached_abundance = abundance
    return deficient if cached_abundance < 0 # deficient return the argument
    return true if cached_abundance == 0 # perfect => semi perfect too

    possible_values = {0=>true} # store all possible values in a hash
    divs = self.divisors # get the divisors

    div_sum_left = divs.inject(0){|a,b|a+b} # get the divisor sum

    pos_2 = div_sum_left - self # this is a possibility too

    divs.reverse.each do |div| # for each divisor
      possible_values.keys.each do |value| # and each possible value
        if value+div_sum_left < self # check wether it can reach the number with the divisors left
          possible_values.delete(value) # if not delete the number (huge speedup)
        end

        new_value = value+div # we create a new possible value including the divisor

        if new_value == self or new_value == pos_2 # if it is the number it's semi perfect
          return true
        elsif new_value < self # if it's less than the number it could be semi perfect
          possible_values[new_value]=true # add it to the possiblities
        end # if it's more than the value we can ignore it
      end
      div_sum_left-=div # the current divisor isn't left anymore
    end
    false # we found no way to compose the number using the divisors
  end


  def restricted_divisor_sum # uses the formular from wikipedia
    distinct_prime_factors.map do |(fac,count)|
      comm_sum = 1
      comm_mul = 1
      count.times do
        comm_sum += (comm_mul*=fac)
      end
      comm_sum
    end.inject(1){|a,b|a*b}-self
  end

  def perfect? # perfect numbers have the form 2**(n-1)*(2**n-1) where n is prime (and small ;) )
    return false if self&1 == 1 # it isn't known weather there are odd perfect numbers.. but it's irrelevant for my algorithm
    doubled = self * 2 # the perfect number is a triangular number of the form (n*(n+1))/2
    doubled_root = Math.sqrt(doubled).floor # if we double it and take the floored square root we get n
    return false unless doubled == doubled_root*(doubled_root+1) # if we don't get n it isn't perfect
    doubled_root_string = (doubled_root+1).to_s(2) # from the first line we know n+1 has to be of the form 2**n
    return false unless doubled_root_string.count('1')==1 # we check that here
    return false unless (doubled_root_string.size-1).prime_factors.size == 1 # and n ha to be a prime
    return false unless self.abundance == 0 # if it passes all the earlier test we check it using the abundance
    true # and if it passes it's perfect
  end

  def abundance
    self.restricted_divisor_sum-self
  end
end


require 'benchmark'

max_num = Integer(ARGV.shift||'1000') rescue 1000 # read a number from the command line

new_semi_perfects = [] # store semi perfect numbers that can't be constructed using other semi perfect numbers



STDOUT.sync = true
puts "Weird Numbers Up To #{max_num}:"


#begin_stat
perfect_count = 0
composed_semi_perfect_count = 0
new_semi_perfect_count = 0
weird_count = 0
deficient_count = 0


record_nums = (1..80).map{|n|max_num*n/80}

record_nums_left = record_nums.dup
next_record = record_nums_left.shift

recorded_times = []


init_time = [Benchmark.times,Time.now]

min_odd = 10**17


#end_stat

  (1..max_num).each do |test_num| # counting loop



    if test_num == next_record #stat
      recorded_times << [Benchmark.times,Time.now] #stat
      next_record = record_nums_left.shift #stat
    end #stat

    if test_num.perfect? # it's perfect
      new_semi_perfects << test_num
      perfect_count += 1 #stat
      next
    end

    do_next = false
    new_semi_perfects.each do |semi_per|
      if test_num % semi_per == 0 # is it possible to compose the current number using a semi-perfect number?
        do_next = true # yes
        composed_semi_perfect_count += 1 #stat
        break
      end
    end
    next if do_next
    # no


    case test_num.semi_perfect? nil # we don't care about deficient numbers
    when true # but we care about semi perfects
      new_semi_perfects << test_num
      new_semi_perfect_count += 1 #stat
    when false # and even more about abundand non semi perfects
      puts test_num
      weird_count += 1 #stat
    else #stat
      deficient_count += 1 #stat
    end

  end

#end

#begin_stat

final_time = [Benchmark.times,Time.now]

digit_length = max_num.to_s.size

def form_float(num)
  "%12s" % ("%im%#{7}ss" % [(num/60).floor,("%.4f" % (num %60))]).tr(" ","0")
end

def rel(x,y)
  "%#{y.to_s.size}i (%6s%%)" % [x,"%3.2f" % (x/y.to_f*100)]
end



puts "Stats"
puts "Time:"
puts "- User:   "+form_float(ut = final_time.first.utime - init_time.first.utime)
puts "- System: "+form_float(st = final_time.first.stime - init_time.first.stime)
puts "- U+S:    "+form_float(ut+st)
puts "- Real:   "+form_float(final_time.last - init_time.last)
puts
puts "Numbers:"
puts "- Total        "+rel(max_num,max_num)
puts "- Weird        "+rel(weird_count,max_num)
puts "- Perfect      "+rel(perfect_count,max_num)
puts "- Deficient    "+rel(deficient_count,max_num)
puts "- Abundand     "+rel(abundand_count = max_num-perfect_count-deficient_count,max_num)
puts "- Semi-Perfect "+rel(abundand_count-weird_count,max_num)
puts "   (w/o perfects)"
puts ""
puts "- Passed 1st   "+rel(max_num-perfect_count,max_num)
puts "   (perfect test)"
puts "- Passed 2nd   "+rel(new_semi_perfect_count+weird_count+deficient_count,max_num)
puts "   (composed test)"
puts "- Passed 3rd   "+rel(new_semi_perfect_count+weird_count,max_num)
puts "   (deficient test)"
puts "- Uncomposed   "+rel(new_semi_perfects.size,max_num)
puts "   (semi-perfects that arn't a multiply of another semi-perfect)"
puts

if recorded_times.size >= 80
  puts "Graphs:"
  puts

  process_plot = []
  real_plot = []

  first_ustime = init_time.first.utime+init_time.first.stime
  first_realtime = init_time.last

  recorded_times.each do |(process_time,realtime)|
    process_plot << process_time.utime+process_time.stime - first_ustime
    real_plot << realtime - first_realtime
  end



  max_process = process_plot.last
  step_process = max_process / 22

  max_real = real_plot.last
  step_real = max_real / 22



  def plot(plot_data,max,step)
    22.downto(0) do |k|
      res = ""
      res = form_float(max) if k == 22
      while res.size != plot_data.size
        val = plot_data[res.size]
        lower_range = k*step
        res << ( val >= lower_range ? (val < lower_range+step ? '#' : ':') : ' ' )
      end
      puts res
    end
  end

  puts "Y: Realtime X: Number"
  plot(real_plot,max_real,step_real)
  puts "%-40s%40s"% [1,max_num]
  puts "Y: System+Usertime X: Number"
  plot(process_plot,max_process,step_process)
  puts "%-40s%40s"% [1,max_num]
  puts
end
#end_stat
