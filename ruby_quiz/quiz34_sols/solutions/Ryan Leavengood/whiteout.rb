# Ruby Quiz: Whiteout (#34)
# Solution by Ryan Leavengood
#
# There are two ways of "whiting out", one that uses a binary
# encoding of spaces and tabs on each line (preserving the
# original newlines), and a ternary encoding that makes newlines
# part of the code and encodes any of the original newlines.  The
# method of encoding is chosen at random.  In theory other
# non-printable characters could be added to increase the radix
# used for encoding, but I think the best cross-platform "whiting
# out" can be had using spaces, tabs and newlines.

REQUIRE_LINE = "require 'whiteout'"

class WhiteoutBinary
  attr_reader :id

  WHITESPACE = " \t"
  DIGITS = '01'

  def initialize
    @id = "  \t\t"
  end

  def paint_on(paper)
    paper.map do |line|
      line.chomp.unpack('b*')[0].tr(DIGITS, WHITESPACE)
    end.join("\n")
  end

  def rub_off(paper)
    paper.map do |line|
      [line.chomp.tr(WHITESPACE, DIGITS)].pack('b*')
    end.join("\n")
  end
end

class WhiteoutTernary
  attr_reader :id

  WHITESPACE = " \t\n"
  DIGITS = '012'
  # This allows up to 22222 ternary, which is 242 decimal, enough
  # for most of ASCII
  DIGIT_LENGTH = 5
  RADIX = 3

  def initialize
    @id = "   \t\t\t"
  end

  def paint_on(paper)
    paper.join.gsub(/./m) do |c|
      c[0].to_s(RADIX).rjust(DIGIT_LENGTH,'0')
    end.tr(DIGITS, WHITESPACE)
  end

  def rub_off(paper)
    paper.join.tr(WHITESPACE, DIGITS).gsub(/.{#{DIGIT_LENGTH}}/) do |d|
      d.to_i(RADIX).chr
    end
  end
end

bottle_holder = [WhiteoutBinary.new, WhiteoutTernary.new]

if $0 == __FILE__
  ARGV.each do |filename|
    wo_name = "#{filename}.wo"
    File.open(wo_name, 'w') do |file|
      whiteout = bottle_holder[rand(2)]
      paper = IO.readlines(filename)
      if paper[0] =~ /^\s*#!/
        file.print paper.shift
      end
      file.puts REQUIRE_LINE
      file.puts whiteout.id
      file.print whiteout.paint_on(paper)
    end
    File.rename(filename, filename+'.bak')
    File.rename(wo_name, filename)
  end
else
  paper = IO.readlines($0)
  paper.shift if paper[0] =~ /^\s*#!/
  paper.shift if paper[0] =~ /^#{REQUIRE_LINE}/
  id = paper.shift.chomp
  whiteout = bottle_holder.find {|bottle| bottle.id == id}
  if whiteout
    eval whiteout::rub_off(paper)
  else
    puts "Error: This does not appear to be a valid whiteout file!"
    exit(1)
  end
end
__END__
