#!/usr/local/bin/ruby -Ku
RX = Hash.new{|h,k|h[k]=/(.{#{(k/4.0).round}})#{'(.)'*(k/2.0).round}(.*)/}
$stdout << ARGF.read.gsub(/((?![\d_])\w){4,}/) do |w|
  (caps = RX[w.split(//u).length].match(w).captures).first +
      caps[1..-2].sort_by { rand }.to_s + caps.last
end
