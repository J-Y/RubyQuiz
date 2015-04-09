class Solver
  class Node
    def initialize(parent, depth)
      @value = nil
      @parent = parent
      @right_filled = false
      if depth > 1
        @left = Node.new(self, depth - 1)
        @right = Node.new(self, depth - 1)
      end
    end

    def down(values, num_open)
      # first try single values
      used = []
      touse = values.dup
      @value = nil
      until touse.empty?
        used << @value if @value
        @value = touse.shift
        @parent.up(used + touse, num_open)
      end

      # now try subexpression if enough values left
      return if values.size < num_open + 2
      @value = nil
      [:+, :-, :*, :/].each do |@op|
        @left.down(values, num_open + 1)
      end
    end

    def up(values, num_open)
      if @right_filled
        @parent.up(values, num_open)
        return
      end

      @right_filled = true
      @right.down(values, num_open - 1)
      @right_filled = false
    end

    def evaluate
      return @value.to_f if @value
      @left.evaluate.send(@op, @right.evaluate)
    end

    def to_s
      return @value.to_s if @value
      "(#@left #@op #@right)"
    end
  end

  def initialize(sources, target)
    @tree = Node.new(self, sources.size)
    @target = target
    @sources = sources
    @best_result = (target * 1000).abs
  end

  def run
    @tree.down(@sources, 0)
  end

  def up(values, num_open)
#    return unless values.empty?  # only allow solutions using all values
    result = @tree.evaluate
    return if result.nan? || @best_result <= (@target - result).abs
    @best_result = (@target - result).abs
    printf "%s = %f\n", @tree, result
    exit if @best_result == 0
  end
end

if ARGV.size < 3
  puts "Usage: ruby slow_countdown.rb <target> <source1> <source2> ..."
  exit
end

solver = Solver.new(ARGV[1..-1].map {|v| v.to_i}, ARGV[0].to_i)
solver.run
