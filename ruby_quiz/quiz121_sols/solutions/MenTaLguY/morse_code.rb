MORSE = Hash[*%w(
  A .-   N -.
  B -... O ---
  C -.-. P .--.
  D -..  Q --.-
  E .    R .-.
  F ..-. S ...
  G --.  T -
  H .... U ..-
  I ..   V ...-
  J .--- W .--
  K -.-  X -..-
  L .-.. Y -.--
  M --   Z --..
)].invert.freeze

class Decoder
  Arc = Struct.new :input, :to, :output
  State = Struct.new :arcs
  Solution = Struct.new :state, :output

  def initialize(code)
    @start = State.new
    @start.arcs = code.map do |input, output|
      raise ArgumentError, "input cannot be empty" if input.empty?
      input.reverse.unpack("C*").inject(@start) do |state, c|
        string, output = output, ""
        State[[Arc[c, state, string]]]
      end.arcs
    end.flatten
  end

  def process(input)
    input.unpack("C*").inject([Solution[@start, ""]]) do |solutions, c|
      break [] if solutions.empty?
      solutions.map do |solution|
        solution.state.arcs.select do |arc|
          arc.input == c
        end.map do |arc|
          Solution[arc.to, solution.output + arc.output]
        end
      end.flatten
    end.select do |solution|
      solution.state.equal? @start
    end.map do |solution|
      solution.output
    end
  end
end

Decoder.new( MORSE ).process( gets.chomp ).sort.each do |result|
  puts result
end
