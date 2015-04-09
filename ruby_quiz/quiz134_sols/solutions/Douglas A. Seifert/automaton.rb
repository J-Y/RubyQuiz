class Automaton
  attr_accessor :rule_number
  attr_reader :rule_map

  FILLED_CHAR = '#'
  EMPTY_CHAR = '0'

  # Construct a new Automaton with the given rule number and initial
  # line width
  def initialize(rule_number, initial_state)
    @rule_number = rule_number
    @chars = initial_state.length
    @num = 0
    initial_state.reverse.split(//).each_with_index do |c, idx|
      @num += 2 ** idx if '1' == c
    end
    initialize_rule_map
  end

  # Sets up the automaton rule map.  Given a 3 byte neighborhood
  # as an integer, tells whether the new center cell is filled or not.
  def initialize_rule_map
    @rule_map = []
    n = @rule_number
    (0..7).each do |idx|
      @rule_map[idx] = n & 1 != 0 ? 1 : 0
      n = n >> 1 unless n == 0
    end
  end

  # Run the automaton.  By default runs 20 iterations.
  def run(iters = 20)
    cols = @chars + iters * 2
    (0..iters).each do |i|
      @num = print_line(@num, @chars, i, cols)
      @chars += 2
    end
  end

  # Print the automaton line and returns next value as an integer.  The
  # value is calculated by assuming the line is a binary number with
  # filled characters being 1's and empty characters being zeros.
  def print_line(num, chars, iter, cols)
    
    # First iter, just print num as a binary
    if iter == 0
      #puts "num #{num} iter #{iter}"
      puts ("%0#{chars}b" % num).gsub("1", FILLED_CHAR).gsub("0", EMPTY_CHAR).center(cols)
      return num
    end

    # special case, num = 0
    if num == 0
      puts (EMPTY_CHAR * chars).center(cols)
      return 0
    end

    # shift it twice to get two trailing zeros
    num = num << 2

    # track return value
    ret = 0

    # calculate and print the line
    line = ""
    (0..chars-1).each do |count|
      # mask off everything but the last three bits to get
      # the index into the rule_map
      idx = num & 7
      if @rule_map[idx] == 1
        line << FILLED_CHAR
        ret += 2 ** count
      else
        line << EMPTY_CHAR
      end
      # Shift to the next position
      num = num >> 1
    end

    # Reverse the line and print it centered
    puts line.reverse.center(cols)

    # Return the value of the current line
    return ret
  end
end


if __FILE__ == $0 
  require 'ostruct'
  require 'optparse'

  options = OpenStruct.new
  options.rule_num = nil
  options.start_state = '1'
  options.iterations = 20
  options.verbose = false

  opts = OptionParser.new do |opts|
    opts.banner = "Usage: ruby automata.rb [options]"
    opts.separator ""

    opts.on("-r", "--rule-number NUMBER",
      "Set the automata rule number, 0-255.") do |rn|
        options.rule_num = rn.to_i
    end

    opts.on("-c", "--cell-state BINARY_STRING",
      "Set the automata starting state, defaults to 1.") do |sn|
        options.start_state = sn
    end

    opts.on("-s", "--steps NUMBER",
      "Set the number of iterations, defaults to 20.") do |i|
        options.iterations = i.to_i
    end

    opts.on("-v", "--verbose",
      "Turn on verbose diagnostic output.") do
        options.verbose = true
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit 1
    end
  end

  opts.parse!(ARGV)

  if options.rule_num.nil?
    puts "Rule number must be specified."
    puts opts
    exit 2
  end

  if options.rule_num < 0 || options.rule_num > 255
    puts "Rule number must be >=0 and <= 255."
    puts opts
    exit 3
  end

  a = Automaton.new(options.rule_num, options.start_state)
  if options.verbose
    puts "start state = '#{options.start_state}'"
    puts "rule_map:"
    (0..7).each { |n| print "%03b" % n; print " " }
    puts
    a.rule_map.each { |n| print "%3b" % n; print " " }
    puts
  end
  a.run(options.iterations)
end
