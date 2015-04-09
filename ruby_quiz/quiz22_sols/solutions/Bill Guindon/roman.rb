require 'optparse'

TITLE = "\nRoman Nvmeral Converter Version: I.IV\n"
HELP = "
  Roman Nvmerals shall be rendered vnto Decimal.
  Decimal Nvmerals shall be rendered vnto Caesar.
"

ARGV.options do |opts|
  opts.banner = "Usage: ruby #{__FILE__} [options] [input files]"
  opts.on('Options:')
  opts.on("--help", "-h", "This text") { puts TITLE, '', opts, HELP; exit 0 }
  opts.parse!
end

DEC_MAP = %w( 0 A AA AAA AB B BA BAA BAAA AC )

DEC_DIGIT = []
DEC_DIGIT << {'A' => 'I', 'B' => 'V', 'C' => 'X'}
DEC_DIGIT << {'A' => 'X', 'B' => 'L', 'C' => 'C'}
DEC_DIGIT << {'A' => 'C', 'B' => 'D', 'C' => 'M'}
DEC_DIGIT << {'A' => 'M', 'B' => '?', 'C' => '?'}

ROMAN={ 'I' => 1 , 'V' => 5 , 'X' => 10 , 'L' => 50 , 'C' => 100 , 'D'
=> 500 , 'M' => 1000 }

results = []

ARGF.each { |number|
  number = number.upcase.chop
  roman = number =~ /^[IVXLCDM]*$/
  decimal = number =~ /^[0-9]*$/
  case

    when roman
      skip = false
      number = number.split('')
      total = 0
      number.each_with_index do |char, idx|
        nextchar = number[idx + 1]
        if skip
          skip = false
        else
          if nextchar && (ROMAN[nextchar] > ROMAN[char])
            total +=  ROMAN[nextchar] - ROMAN[char]
            skip = true
          else
            total += ROMAN[char]
          end
        end
      end
      results << total

    when decimal
      number = number.split('').reverse
      number.each_with_index do |place, idx|
        number[idx] = DEC_MAP[place.to_i].split('')
        number[idx].collect! do |char|
          char = DEC_DIGIT[idx][char]
        end
        number[idx].join
      end
      number = number.reverse.join('')
      results << number

    else
      results << "Nothing"
  end
}

results.each {|result| puts result}
