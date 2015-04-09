#!/usr/local/bin/ruby -w --
#
# TumbleDRYer - a program to remove repetitions from a file
# Hugh Sasse
#
#


class TumbleDRYer
  BUFFERSIZE = 1024
  SHORTEST = 4
  FEWEST = 2
  def initialize(input = STDIN)
    @suffices = Array.new
    @suffices_size = nil
    # Suffix array due to Jon Bentley, Programming Pearls.
    @ziv_lempel_dict = Hash.new(0)
    case input
    when String
      File.open(input) do |inf|
        get_input(inf)
      end
      build_suffices()
    when IO
      get_input(input)
      build_suffices()
    else
      raise "unknown input #{input}"
    end
  end

  def get_input(source)
    string = source.read()
    # string = Regexp.quote(string)
    @buffer = string.split(/\b/)
    # so buffer is an array of strings.
    @buffer.freeze
  end

  def build_suffices()
    0.upto(@buffer.size) {|i| @suffices << i}
    # so suffices in a collection of indices into buffer.
    @suffices = @suffices.sort_by do |v|
      @buffer[v..-1].join()
      # i.e an alphanumeric case sensitive search.
    end
    @suffices.freeze
    @suffices_size = @suffices.size
    # puts "Suffices is #{@suffices.inspect}"
  end

  def substring(an_index)
    # puts "in substring index is #{index} " # #{caller[0]}"
    result = @buffer[@suffices[an_index]..-1].join('')
    # puts "substring(#{an_index}) is #{result}"
    return result
  end

  def buf_string(start, chars)
    elems = 1
    origin = @suffices[start]
    result = @buffer[origin]
    until result.length >= chars do
      result += @buffer[origin+elems]
      elems += 1
    end 
    return result[0, chars]
  end

  def build_ziv_lempel()
    0.upto(@suffices_size - 2) do |ind|
      # puts "in build_ziv_lempel index is #{index}"
      sb1=substring(ind)
      sb2=substring(ind+1)
      len=sb1.common_length(sb2)
      next if len.zero?
      # puts "len is now #{len} for '#{sb1[0..20]}...','#{sb2[0..20]}...'in build_ziv_lempel"
      count = 1
      ic1 = ind + count + 1
      while (ic1 < @suffices_size) and (sb1.common_length(substring(ic1)) == len)
        count += 1
        ic1 += 1
      end
      @ziv_lempel_dict[ind] = [len, count]
    end
    # puts "ziv_lempel_dict is #{@ziv_lempel_dict.inspect}"
  end

  def ziv_lempel_ordered
    # remove things that only happen once.
    @ziv_lempel_dict.delete_if do |k,v|
      v[0] < SHORTEST or v[1] < FEWEST 
      # @buffer[@suffices[k],v[0]] =~ /^\s+/ or
      # @buffer[@suffices[k],v[0]] =~ /\s+$/
      # don't substitute for whitespace chunks, they improve
      # readability
    end
    # Sort by product of lenght * occurrences, then length, then where
    # it occurred.
    results = @ziv_lempel_dict.sort_by{|k,v| [v[0]*v[1],v,k]}.reverse
    # puts "results is #{results.size} elements"
    # puts results.inspect 
    # results.each do |ary|
      # puts "%Q{#{buf_string(ary[0],ary[1][0])}} #{ary.inspect}"
    # end
    return results
  end

  # Produce the code to regenerate the input.
  def output
    results = ziv_lempel_ordered
    # results.each do |ary|
      # puts "now: %Q{#{buf_string(ary[0],ary[1][0])}} #{ary.inspect}"
    # end
    the_output = @buffer.join('')
    variable = "@a"
    variables = Array.new
    results.each do |ary|
      string = buf_string(ary[0],ary[1][0])
      count = 0
      re = Regexp.new(Regexp.quote(string))
      the_output.gsub(re) do |s|
        count += 1
        s
      end
      if count >= 2
        variables << [variable.dup, string.dup]
        the_output.gsub!(re, "\#\{#{variable}\}")
        variable.succ!
      else
        # puts "string #{string} /#{re}/ not found"
      end
    end
    print <<EOF
#!/usr/local/bin/ruby -w --

# Takes DRY code and soaks it... undoes TumbleDRYer.
class WashingMachine
  def initialize
EOF
    variables.each do |ary|
      puts "    #{ary[0]} = %q{#{ary[1]}}"
    end
    print <<EOF
  end
  def output
    # We need a string unlikely to be in the input as a terminator.
    print <<BLOBULARIZATION
EOF
    puts the_output 
    print <<EOF
BLOBULARIZATION
  end
end

WashingMachine.new.output
EOF
  end
end

  module Enumerable
    def common_length(other)
      c = 0
      len = self.size > other.size ? other.size : self.size ;
      0.upto(len-1) do |i|
        # puts "self[i] is #{self[i].inspect}"
        # puts "other[i] is #{other[i].inspect}"
        if self[i] == other[i]
          c += 1
        else
          break
        end
      end
      # l = self.length < 20 ? self.length : 20 ;
      # m = other.length < 20 ? other.length : 20 ;

      # puts " common_length(): #{self[0..l]}, #{other[0..m]} => #{c}"

      return c
    end

  end

  print "Enter Filename: "
  name = STDIN.gets.chomp 
  td = TumbleDRYer.new(name)
  puts
  puts
  td.build_ziv_lempel
  puts
  puts
  td.output
