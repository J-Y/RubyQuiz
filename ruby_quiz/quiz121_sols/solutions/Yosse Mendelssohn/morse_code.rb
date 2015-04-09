class String

  class << self
    def morse_code_hash=(new_val)
      @@morse_code_hash = new_val
    end

    def morse_code_hash
      @@morse_code_hash
    end
  end

  def morsecode_possibilities
    raise "#{self} is not valid morse code" if self.match(/[^\-\.]/)

    @tree = get_tree

    @possibilities = @tree.flatten.keys.sort
  end

  def get_tree
    starts = @@morse_code_hash.keys.select { |k|  self.match(/^#{Regexp.escape(k)}/) }

    tree = {}

    starts.each do |start|
      tree[ @@morse_code_hash[start] ] = self[start.length .. -1].get_tree
    end

    tree
  end

end

class Hash
  def flatten
    tmp = {}
    each do |key, val|
      tmp[key] = val
      if val.is_a?(Hash)
        val.keys.each do |subkey|
          tmp["#{key}#{subkey}"] = val[subkey]
        end
        tmp.delete(key) unless val.empty?
      end
    end
    tmp = tmp.flatten while tmp.values.any? { |v|  !v.empty? }
    tmp
  end
end

codehash = {
  'A' => '.-',
  'B' => '-...',
  'C' => '-.-.',
  'D' => '-..',
  'E' => '.',
  'F' => '..-.',
  'G' => '--.',
  'H' => '....',
  'I' => '..',
  'J' => '.---',
  'K' => '-.-',
  'L' => '.-..',
  'M' => '--',
  'N' => '-.',
  'O' => '---',
  'P' => '.--.',
  'Q' => '--.-',
  'R' => '.-.',
  'S' => '...',
  'T' => '-',
  'U' => '..-',
  'V' => '...-',
  'W' => '.--',
  'X' => '-..-',
  'Y' => '-.--',
  'Z' => '--..'
}


String.morse_code_hash = codehash.invert

code = (ARGV.first || '').chomp

exit if code.empty?

puts "Getting possibilities for '#{code}':"

puts code.morsecode_possibilities.join("\n")
