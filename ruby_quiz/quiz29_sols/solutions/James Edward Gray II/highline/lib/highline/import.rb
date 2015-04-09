#!/usr/local/bin/ruby -w

#  import.rb
#
#  Created by James Edward Gray II on 2005-04-26.
#  Copyright 2005 Gray Productions. All rights reserved.

require "highline"

$terminal = HighLine.new

class Object
	def agree( yes_or_no_question )
		$terminal.agree(yes_or_no_question)
	end
	
	def ask( question, answer_type = String, &details )
		$terminal.ask(question, answer_type, &details)
	end
	
	def say( statement )
		$terminal.say(statement)
	end
end
