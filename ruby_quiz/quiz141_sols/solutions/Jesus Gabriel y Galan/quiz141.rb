# quiz141.rb
# 29 September 2007
#

require 'main'

$compare_types = {"at_least" => :>=, "exactly" => :==, "no_more_than" => :<=,
                  "more_than" => :>, "less_than" => :<}

main {
  argument('dice') {
    cast :int
    description "number of dice to throw"
  }
  argument('num') {
    cast :int
    description "number of fives to count in each throw"
  }
  option('verbose', 'v') {
    description "verbose mode: will show all combinations"
  }
  option('samples', 's') {
    description "sample mode: will show 1 combination every 50000"
  }
  option('type', 't') {
    argument :required
    defaults "at_least"
    validate {|type| $compare_types.keys.include?(type)}
    description "Type of comparison. Possible values: " + $compare_types.keys.join(",")
  }

def run
  verbose = params[:verbose].given?
  samples = params[:samples].given?
  dice = params[:dice].value
  num = params[:num].value
  type = params[:type].value
  method = $compare_types[type]
  puts "Checking #{type} #{num} fives throwing #{dice} dice"
  puts "Verbose mode" if verbose
  puts "Samples mode" if samples
  current = Array.new(dice) {1}
  current[0] = 0 # to start the loop incrementing the first element
  total_matches = 0
  total_iter = 0
  begin
    total_iter += 1
    (0...dice).each do |i|
      if (current[i] < 6)
        current[i] += 1
        break
      else
        current[i] = 1
      end
    end
    match = current.select {|x| x == 5}.size.send(method, num)
    total_matches += 1 if match
    if (verbose || (samples && total_iter%50000 == 1))
      print total_iter, " ", current.inspect
        puts "#{match ?'<==':''}"
    end
  end while current.any?{|x|x != 6}
  puts "Number of desirable outcomes: #{total_matches}"
  puts "Number of possible outcomes: #{total_iter}"
  puts "Probabilty is #{total_matches.to_f/total_iter.to_f}"
end
}
