require 'pp'

module Compressor
  # gets all compressed versions of str
  def self.compress(str, len, ellipses = '...')
    len = len.to_i
    return case 
           when str.size <= len
             [str]
           else
             ret = []
             weight = {}
              cutout = str.size - len + ellipses.size - 1
             (0..(len-ellipses.size)).to_a.each do |i|
               a = str.dup
               a[i..(i + cutout)] = ellipses 
               w = 0
               #weight by distance of cutout from middle of word (middle being highest)
               ideal = (str.size - cutout) / 2
               w += i if i <= ideal
               w += (ideal * 2) - i if i > ideal
               [' ', '_', '-', '.'].each do |c|
                w += 1 if str[i..(i+cutout)].include?(c)
               end
               ret << a
               weight[a] = w

             end

             ret.sort{|s1, s2| weight[s2] <=> weight[s1] }
           end
  end

  def self.compress_array(arr, len, ellipses = '...')
    candidates = {}
    arr.each { |s| candidates[s] = self.compress(s, len, ellipses) }

    results = {}
    candidates.each { |k, v|
      # first try to find a completely unique abbreviation
      results[k] = v.find { |s| 
        candidates.all? { |k2, v2| k2 == k or !v2.include?(s)}
      }

      # if none was found, just pick one that's different from the other chosen ones
      results[k] = v.find { |s| !results.values.include?(s) } if results[k].nil?

      # if we still don't have one, pick the first one (heighest weighted) 
      results[k] = v.first if results[k].nil?
    }
    arr.collect{ |s| results[s] }
  end
end

class Array
  def compress(len = 10)
    Compressor.compress_array(self, len)
  end
end

pp ARGV[1..-1].compress(ARGV[0])
