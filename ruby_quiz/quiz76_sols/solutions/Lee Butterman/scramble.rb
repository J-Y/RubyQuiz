class String
  def shuffle() split('').sort_by {rand}.join end
end

def munge s
  eac_wor_ = /[a-z]+(?=[a-z])/i
  s.gsub(eac_wor_)  {|s| s[0..0]+s[1..-1].shuffle}
end

while gets
  print munge($_)
end
