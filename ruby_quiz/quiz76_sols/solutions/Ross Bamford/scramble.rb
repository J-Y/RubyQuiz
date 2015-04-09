#!/usr/local/bin/ruby -Ku
$stdout << ARGF.read.gsub(/\B((?![\d_])\w{2,})\B/) do |w|
  $&.split(//).sort_by { rand }
end
