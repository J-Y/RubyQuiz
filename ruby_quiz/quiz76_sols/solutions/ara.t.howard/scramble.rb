class String
  def scramble on = ''
    re = %r/( (?:\b \w \w{2,} \w \b) | \s+ | . )/iox
    scan(re){|words| on << words.first.scrambled}
    on
  end
  def scrambled
    self[1..-2] = self[1..-2].split(%r//).sort_by{rand}.to_s if size >= 4
    self
  end
end
ARGF.read.scramble STDOUT
