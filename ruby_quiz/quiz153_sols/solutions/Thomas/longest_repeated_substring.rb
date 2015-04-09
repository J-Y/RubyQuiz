#!/usr/bin/env ruby

class String
  def longest_substring_st4
       suffixes = Array.new(size) {|i| self[i..size]}
       suffixes.sort!
       common = ''
       comlen = 0
       suffixes.each_with_index do |curr, index|
           next if index == 0
           curridx = size - curr.size
           pindex  = index - 1
           pindex.downto(pindex - comlen) do |i|
               pred    = suffixes[i]
               psize   = pred.size
               predidx = size - psize
               maxlen  = [(predidx - curridx).abs, psize].min - 1
               next if maxlen < comlen
               prefix  = pred[0 .. comlen]
               break if prefix != curr[0..comlen]
               (comlen + 1 .. maxlen).each do |i|
                   p = pred[i]
                   c = curr[i]
                   if p == c
                       prefix << p
                   else
                       break
                   end
               end
               common = prefix
               comlen = common.size
               break if comlen <= maxlen
           end
       end
       return common
   end
end


if __FILE__ == $0
   if ARGV.empty?
       puts String.new(STDIN.read).longest_substring_st4
   else
       ARGV.each {|f| puts String.new(File.read(f)).longest_substring_st4}
   end
end
