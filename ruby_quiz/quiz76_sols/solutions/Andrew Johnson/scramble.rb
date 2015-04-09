require 'text/hyphen'
hyp  = Text::Hyphen.new :left => 1, :right => 1
text = ARGF.read
text.gsub!(/[^\W\d_]+/) do |m|
  hyp.visualize(m).split(/(^\w|\w$)|-/).map{|t|
    t.split(//).sort_by{rand}.join
  }.join
end
puts text
