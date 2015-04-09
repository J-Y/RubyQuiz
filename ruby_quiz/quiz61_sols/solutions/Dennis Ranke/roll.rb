module Dice
  def self.roll(expr)
    expr = expr.gsub(/\s/, '')
    while
      expr.sub!(/\(([^()]+)\)/) { roll($1) } ||
      expr.sub!(/(\A|[^\d])\-\-(\d+)/, '\\1\\2') ||
      expr.sub!(/d%/, 'd100') ||
      expr.sub!(/(\d+)d(\d+)/) { (1..$1.to_i).inject(0) {|a, b| a + rand($2.to_i) + 1} } ||
      expr.sub!(/d(\d+)/, '1d\\1') ||
      expr.sub!(/(\d+)\/(\-?\d+)/) { $1.to_i / $2.to_i } ||
      expr.sub!(/(\d+)\*(\-?\d+)/) { $1.to_i * $2.to_i } ||
      expr.sub!(/(\-?\d+)\-(\-?\d+)/) { $1.to_i - $2.to_i } ||
      expr.sub!(/(\-?\d+)\+(\-?\d+)/) { $1.to_i + $2.to_i }
    end
    return $1.to_i if /\A(\-?\d+)\Z/ =~ expr
    raise "Error evaluating dice expression, stuck at '#{expr}'"
  end
end

(ARGV[1] || 1).to_i.times { print "#{Dice.roll(ARGV[0])}  " }
puts
