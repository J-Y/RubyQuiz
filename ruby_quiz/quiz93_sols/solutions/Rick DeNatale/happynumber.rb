#! /usr/local/bin/ruby

class Integer

       def Integer.reset_happiness_cache
               # Integer#to_s(base) works up to a base of 36
               @@cached_unhappy_ints = Array.new(37) {|i| Hash.new }
               @@cached_happiness_paths = Array.new(37) {|i| {1 => [1]}}

               self.cache_unhappy([0, 4, 16, 20, 37, 42, 58, 89, 145], 10)
       end

       def Integer.show_hc
               puts "unhappies = #{@@cached_unhappy_ints[10].inspect}"
               puts "happies = #{@@cached_happiness_paths[10].inspect}"
       end

       def squared
               self * self
       end

       def sum_squares_of_digits(base=10)
               sum = 0
               to_s(base).each_byte do |b|
                       sum += (b.chr.to_i(base)).squared
               end
               sum
       end

       def path_to_happiness(base=10,seen=[])
               return nil if Integer.known_unhappy?(self, base)
               return Integer.cache_unhappy([self], base) if seen.include?(self)
               known_path = Integer.known_happiness_path(self, base)
               return known_path.dup if known_path
               rest_of_the_way = sum_squares_of_digits(base).path_to_happiness(base,seen.dup << self)
               if rest_of_the_way
                       ans = rest_of_the_way.unshift(self)
                       return Integer.cache_happiness_path(ans, base).dup
               else
                       Integer.cache_unhappy([self], base)
                       return nil
               end
       end

       def Integer.known_unhappy?(int, base)
               @@cached_unhappy_ints[base][int]
       end

       def Integer.known_happiness_path(int, base)
               @@cached_happiness_paths[ base][int]
       end

       def known_happy?(base)
               Integer.known_happiness_path(self, base)
       end

       def Integer.cache_unhappy(integers, base)
               integers.each do | n |
                       @@cached_unhappy_ints[base][n] = true
               end
               nil
       end

       def Integer.cache_happiness_path(path, base)
               @@cached_happiness_paths[base][path[0]] = path.dup
               path
       end

       def happy?
               !self.path_to_happiness.nil?
       end

       def happiness
               path = path_to_happiness
               path_to_happiness ? path_to_happiness.length : 0
       end

       reset_happiness_cache
end


 #generates all numbers in the given range whose digits are in
 #nondecreasing order. the order in which the numbers are generated is
 #undefined, so it's possible for 123 to appear before 23, for
 #example.
 # Thanks to Ken Bloom for this idea, which I generalized to an arbitrary base
 #
 def nondec_digits(range,base=10,&b)
         yield 0 if range.first<=0
         (1..base-1).each { |x| nondec_digits_internal(x,x,range,base,&b) }
 end

 def nondec_digits_internal(last,accum,range,base,&b)
         (last..base-1).each do |x|
                 iaccum=accum*base+x
                 b.call(iaccum) if range.nil? || range.include?(iaccum)
                 nondec_digits_internal(x,iaccum,range,base,&b) if iaccum <= range.last
         end
 end

 # enumerate all numbers whose representation in base _base_
 # has increasing digits.
 def nondec_numbers(base, &b)
         start = 0
         ten_in_base = "10".to_i(base)
         stop = ten_in_base
         while true
                 nondec_digits((start..stop-1), base, &b)
                 start = stop
                 stop *= ten_in_base
         end
 end


def happiest_in_range(range, base=10)
       happiest = 1
       max_path_length = 1
       probes = 0
       nondec_digits(range,base) do |i|
               probes += 1
               path = i.path_to_happiness(base)
               if path && path.length > max_path_length
                       happiest = i
                       max_path_length = path.length
               end
       end
       [happiest, max_path_length, probes]
end

def base_levels(base=10)
       ten_in_base = "10".to_i(base)
       start = 0
       base_n = ten_in_base
       n = 1
       while true
               h, pl, probes = happiest_in_range((start..base_n-1), base)
               puts "one of the happiest #{n} digit base #{base} numbers is #{h.to_s(base)}, with #{pl} steps after #{probes} probes"
               start = base_n
               n += 1
               base_n *= ten_in_base
       end
end

# return the happiest number that can be found in time_limit seconds
def happiest(time_limit=60, base=10)
       time_to_stop = Time.now + time_limit
       happiest = 1
       max_path_length = 1
       probes = 0
       nondec_numbers(base) do |i|
               break if Time.now > time_to_stop
               probes += 1
               path = i.path_to_happiness(base)
               if path && path.length > max_path_length
                       happiest = i
                       max_path_length = path.length
               end
       end

       puts "happiest base #{base} number found in #{time_limit} seconds in #{probes} probes"
       puts "was #{happiest.to_s(base)} which has a happiness of #{max_path_length}"
end


require 'optparse'
opts = OptionParser.new
base = 10
time_limit = 600 # default to 10 minutes
happiest_test = true
opts.on("-b", "--base VAL", Integer) {|val| base = val}
opts.on("--levels") {happiest_test = false}
opts.on("-t", "--time-limit VAL", Integer) {|val| time_limit = val}
opts.parse(ARGV)
happiest(time_limit, base) if happiest_test
base_levels(base) unless happiest_test
