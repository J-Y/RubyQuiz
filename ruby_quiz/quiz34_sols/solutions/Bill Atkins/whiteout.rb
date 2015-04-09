if __FILE__ == $0
  # invoked as an exectuable
  ARGV.each do |file|
    source = File.read(file)

    # save the shebang (if there is one)
    shebang = nil
    source.sub /^(\#!.*?)\n/ do |m| shebang = m; "" end

    # convert the remaining text to whitespace; a given line will
    # contain n spaces, where n is the ASCII code of the character
    # that line represents tabs (\t) are used to represent 16 spaces

    result = source.split(//).collect do |char|
      ascii = char[0]

      "\t" * (ascii / 16) + " " * (ascii % 16)
    end.join "\n"

    result = "require 'whiteout'\n" + result
    File.open file, "w" do |f| f.write result end
  end
else
  # required as a library

  source = File.read $PROGRAM_NAME

  source.sub! /^.*?require 'whiteout'\n/, ""

  result = source.split(/\n/).collect do |line|
    ascii = 0
    line.each_byte do |c|
      if c.chr == "\t"
        ascii += 16
      elsif c.chr == " "
        ascii += 1
      else
        raise "invalid input: #{c.chr}"
      end
    end

    ascii.chr
  end.join ""

  eval result
end
