#!/usr/bin/env ruby

require "yaml"

class AnimalTree
	def initialize( question, yes = nil, no = nil )
		@question	= question
		@yes		= yes
		@no			= no
	end
	
	attr_reader :yes, :no
	
	def question
		if animal?
			"Is it #{@question}?  (y or n)"
		else
			"#{@question}  (y or n)"
		end
	end
	
	def learn( question, other, yes_or_no )
		if yes_or_no =~ /^\s*y/i
			@yes	= AnimalTree.new(other)
			@no		= AnimalTree.new(@question)
		else
			@yes	= AnimalTree.new(@question)
			@no		= AnimalTree.new(other)
		end
		@question = question
	end
	
	def animal?
		@yes.nil? and @no.nil?
	end
	
	def to_s
		@question
	end
end

### Load Animals ###

if test(?e, "animals.yaml")
	animals = File.open("animals.yaml") { |f| YAML.load(f) }
else
	animals = AnimalTree.new("an elephant")
end

### Interface ###

puts "Think of an animal..."
sleep 3
quiz = animals
loop do
	puts quiz.question
	response = $stdin.gets.chomp
	if quiz.animal?
		if response =~ /^\s*y/i
			puts "I win.  Pretty smart, aren't I?"
		else
			puts "You win.  Help me learn from my mistake before you go..."
			puts "What animal were you thinking of?"
			other = $stdin.gets.chomp
			puts "Give me a question to distinguish #{other} from #{quiz}."
			question = $stdin.gets.chomp
			puts "For #{other}, what is the answer to your question?  (y or n)"
			answer = $stdin.gets.chomp
			puts "Thanks."
			quiz.learn(question, other, answer)
		end
		puts "Play again?  (y or n)"
		response = $stdin.gets.chomp
		if response =~ /^\s*y/i
			puts "Think of an animal..."
			sleep 3
			quiz = animals
		else
			break
		end
	else
		if response =~ /^\s*y/i
			quiz = quiz.yes
		else
			quiz = quiz.no
		end
	end
end

### Save Animals ###

File.open("animals.yaml", "w") { |f| YAML.dump(animals, f) }
