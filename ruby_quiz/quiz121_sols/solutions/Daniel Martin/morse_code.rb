#!ruby -x

# Copied from quiz description, with a regexp search/replace that
# my editor (SciTE) made easy to do:
MORSE = [
%w{A .-}, %w{N -.},
%w{B -...}, %w{O ---},
%w{C -.-.}, %w{P .--.},
%w{D -..}, %w{Q --.-},
%w{E .}, %w{R .-.},
%w{F ..-.}, %w{S ...},
%w{G --.}, %w{T -},
%w{H ....}, %w{U ..-},
%w{I ..}, %w{V ...-},
%w{J .---}, %w{W .--},
%w{K -.-}, %w{X -..-},
%w{L .-..}, %w{Y -.--},
%w{M --}, %w{Z --..},
].map {|c, morse| [c, /^#{Regexp.escape(morse)} ?(.*)/]}.sort;

# Given a morse-code input string, yield the initial letter we
# could be starting with and the rest of the morse code string.
def get_letters(instr)
    MORSE.each { |c, re|
        if (instr =~ re) then
          yield c,$1
        end
    }
end

# Generate all possible decodings of the given morse code string.
# The algorithm's pretty simple - the only twist is storing the
# intermediate results in a hash so that they don't get calculated
# more than once.
def gencode(instr)
    memoizer = Hash.new { |h,morse|
        retval = []
        get_letters(morse) { |c,rest|
            h[rest].each {|s| retval << (c+s)}
        }
        h[morse] = retval
    }
    memoizer[''] = ['']
    memoizer[instr]
end

# And that's it as far as the fundamental algorithm is concerned.
# The rest is all option handling and dictionary filtering

$dictfunc = lambda {|x| 1}
$opt_m = nil
$usage = "morse.rb [-d dictionary] [-m] [codestring]"

while ARGV[0] and ARGV[0] =~ /^-/ do
    case ARGV[0]
    when /^-d/
        dictionary = {}
        File.open(ARGV[1]) { |f| f.each { |w|
            w.chomp!.upcase!.strip!
            dictionary[w] = 1
        } }
        $dictfunc = lambda {|x| dictionary[x]}
        ARGV.shift
    when /^-m/
        $opt_m = 1
    else
        STDERR.puts "Unknown option #{ARGV[0]}"
        STDERR.puts $usage
        exit 1
    end
    ARGV.shift
end

if ARGV[0] then
    if ARGV[1] then
        STDERR.puts $usage
        exit 1
    end
    gencode(ARGV[0]).select{|w|$dictfunc.call(w)}.each{|w| puts w}
    exit 0 unless $opt_m
end

STDIN.each do |l|
    gencode(l).select{|w|$dictfunc.call(w)}.each{|w| puts w}
    exit 0 unless $opt_m
end
