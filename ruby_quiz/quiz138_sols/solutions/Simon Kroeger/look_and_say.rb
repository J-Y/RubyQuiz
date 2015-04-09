class String
  def look_and_say
    gsub(/(.)\1*/){|s| "#{s.size}#{s[0,1]}"}
  end
end

s = '1'
12.times {p s; s = s.look_and_say}
