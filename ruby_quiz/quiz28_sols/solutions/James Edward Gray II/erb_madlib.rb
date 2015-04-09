#!/usr/local/bin/ruby -w

# use Ruby's standard template engine
require "erb"

# storage for keyed question reuse
$answers = Hash.new

# asks a madlib question and returns an answer
def q_to_a( question )
	question.gsub!(/\s+/, " ")       # noramlize spacing
	
	if $answers.include? question    # keyed question
		$answers[question]
	else                             # new question
		key = if question.sub!(/^\s*(.+?)\s*:\s*/, "") then $1 else nil end
		
		print "Give me #{question}:  "
		answer = $stdin.gets.chomp
		
		$answers[key] = answer unless key.nil?
		
		answer
	end
end

# usage
unless ARGV.size == 1 and test(?e, ARGV[0])
	puts "Usage:  #{File.basename(__FILE__)} MADLIB_FILE"
	exit	
end

# load Madlib, with title
madlib = "\n#{File.basename(ARGV[0], '.madlib').tr('_', ' ')}\n\n" +
         File.read(ARGV[0])
# convert ((...)) to <%= q_to_a('...') %>
madlib.gsub!(/\(\(\s*(.+?)\s*\)\)/, "<%= q_to_a('\\1') %>")
# run template
ERB.new(madlib).run
