# Ruby Quiz 121
# Donald A. Ball Jr.
# Version 1.1
class String
  def split_at(index)
    [slice(0, index), slice(index, length)]
  end
end

class Morse

  CODES = {
    :A => '.-',
    :B => '-...',
    :C => '-.-.',
    :D => '-..',
    :E => '.',
    :F => '..-.',
    :G => '--.',
    :H => '....',
    :I => '..',
    :J => '.---',
    :K => '-.-',
    :L => '.-..',
    :M => '--',
    :N => '-.',
    :O => '---',
    :P => '.--.',
    :Q => '--.-',
    :R => '.-.',
    :S => '...',
    :T => '-',
    :U => '..-',
    :V => '...-',
    :W => '.--',
    :X => '-..-',
    :Y => '-.--',
    :Z => '--..'
  }

  def self.decipher(cipher)
    CODES.each_pair do |letter, code|
      prefix, suffix = cipher.split_at(code.length)
      next unless prefix == code
      if suffix == ''
        yield letter.to_s
      else
        decipher(suffix) {|result| yield letter.to_s << result }
      end
    end
  end

end

Morse.decipher(ARGV[0]) {|word| puts word}