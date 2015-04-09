# file: cell.rb
# author: drew olson

class CellAutomata
  require 'enumerator'

  def initialize rule
    raise ArgumentError if rule < 0 || rule > 255
    @rule_table = build_table rule
  end

  # simulate a given number of generations. return in string format
  def simulate cur_gen, num_gen
    @max_gen ||= num_gen+1
    raise ArgumentError if num_gen < 0
    if num_gen == 0
      format_gen(cur_gen,num_gen)
    else
      format_gen(cur_gen,num_gen) + simulate(build_new_gen(cur_gen),num_gen-1)
    end
  end

  private

  # format a generation for printing
  def format_gen gen,num_gen
    ("%0#{@max_gen+(@max_gen-num_gen)}d" % gen).gsub(/0/,' 
').gsub(/1/,'X')+"\n"
  end

  # build new generation based on current generation
  def build_new_gen gen
    new_gen = ''
    ('00'+gen+'00').split(//).each_cons(3) do |group|
      new_gen += @rule_table[group.join('').to_i(2)]
    end
    new_gen
  end

  # build rule table based on a number seed
  def build_table rule
    rule_string = ("%08d" % rule.to_s(2)).split(//).reverse.to_s
    (0..7).inject({}) do |rule_table,i|
      rule_table[i] = rule_string[i,1]
      rule_table
    end
  end
end

# create automation based on command line args
if __FILE__ == $0 || true
  cell = CellAutomata.new(ARGV[0].to_i)
  puts cell.simulate(ARGV[2],ARGV[1].to_i)
end
