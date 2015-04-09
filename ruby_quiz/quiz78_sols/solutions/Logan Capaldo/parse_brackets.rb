require 'brackets.tab'
class BracketParser
  def parse_str(str)
    list_of_tokens = str.split(//).map { |x| [x, x] }
    list_of_tokens << [false, false]
    yyparse(list_of_tokens, :each)
  end
end

parser = BracketParser.new
ARGF.each do |line|
  line = line.chomp
  begin
    parser.parse_str(line)
    puts line
  rescue Racc::ParseError
    exit(1)
  end
end
