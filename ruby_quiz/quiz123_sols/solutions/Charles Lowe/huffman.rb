module Huffman
  module_function
  def get_frequencies text
    hash = Hash.new 0
    text.split(//).each { |c| hash[c] += 1 }
    hash
  end

  def make_table freqs
    freqs = freqs.to_a.sort_by { |a, b| [-b, a] }
    return [freqs[0][0], '0'] if freqs.length == 1
    total = freqs.transpose[1].inject { |a, b| a + b }
    # find the point at which to partition it
    sum = 0
    point = (total + 1) / 2
    i = (freqs.index freqs.find { |a, b| sum += b; sum >= point } rescue freqs.length - 1)
    table = []
    %w[0 1].zip([freqs[0..i], freqs[i+1..-1]]).each do |prefix, set|
      if set.length == 1
        table << [set.first[0], prefix]
      else
        table += make_table(set).map { |a, b| [a, prefix + b] }
      end
    end
    table
  end

  def encode text, table=nil
    encode_hash = Hash[*(table || make_table(get_frequencies(text))).flatten]
    text.split(//).map { |c| encode_hash[c] or raise "#{c.inspect} not in table" }.join
  end
end

if __FILE__ == $0
  s = ARGV.join ' '
  bits = Huffman.encode s
  before, after = s.length, (bits.length / 8.0).ceil
  puts "Encoded: "
  puts bits.scan(/(.{1,8})/).join(' ') + "\n\n"
  puts "#{before} => #{after} (#{(100 - after.to_f/before * 100).round}%)"
end