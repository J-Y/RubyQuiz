#!/usr/local/bin/ruby -w

require "erb"

# Glenn Parker's code from Ruby Quiz 25...
require "english_numerals"
class Integer
	alias_method :to_en, :to_english
end

class Array
	def insert_at_nil( obj )
		if i = index(nil)
			self[i] = obj
			i
		else
			self << obj
			size - 1
		end
	end
end

module MathCaptcha
	@@captchas = Array.new
	@@answers  = Array.new
	
	def self.add_captcha( template, &validator )
		@@captchas << Array[template, validator]
	end
	
	def self.create_question
		raise "No captchas loaded." if @@captchas.empty?
		
		captcha = @@captchas[rand(@@captchas.size)]
		
		args = Array.new
		class << args
			def arg( value )
				push(value)
				value
			end
			
			def resolve( template )
				ERB.new(template).result(binding)
			end
		end
		question = args.resolve(captcha.first)
		index    = @@answers.insert_at_nil(Array[captcha.first, *args])
		
		Hash[:question  => question, :answer_id => index]
	end
	
	def self.check_answer( answer )
		raise "Answer id required." unless answer.include? :answer_id
		
		template, *args = @@answers[answer[:answer_id]]
		raise "Answer not found." if template.nil?
		
		validator = @@captchas.assoc(template).last
		raise "Unable to match captcha." if validator.nil?
		
		if validator[answer[:answer], *args]
			@@answers[answer[:answer_id]] = nil
			true
		else
			false
		end
	end
	
	def self.load_answers( file )
		@@answers = File.open(file) { |answers| Marshal.load(answers) }
	end
	
	def self.load_captchas( file )
		code = File.read(file)
		eval(code, binding)
	end

	def self.save_answers( file )
		File.open(file, "w") { |answers| Marshal.dump(@@answers, answers) }
	end
end

if __FILE__ == $0
	captchas = File.join(ENV["HOME"], ".math_captchas")
	unless File.exists? captchas
		File.open(captchas, "w") { |file| file << DATA.read }
	end
	MathCaptcha.load_captchas(captchas)
	
	answers = File.join(ENV["HOME"], ".math_captcha_answers")
	MathCaptcha.load_answers(answers) if File.exists? answers

	END { MathCaptcha.save_answers(answers) }

	if ARGV.empty?
		question = MathCaptcha.create_question
		puts "#{question[:answer_id]} : #{question[:question]}"
	else
		args = Hash.new
		while ARGV.size >= 2 and ARGV.first =~ /^--\w+$/
			key       = ARGV.shift[2..-1].to_sym
			value     = ARGV.first =~ /^\d+$/ ? ARGV.shift.to_i : ARGV.shift
			args[key] = value
		end
		
		answer = MathCaptcha.check_answer(args)
		puts answer

		exit(answer ? 0 : -1)
	end
end

__END__
add_captcha(
	"<%= arg(rand(10)).to_en.capitalize %> plus <%= arg(2).to_en %>?"
) do |answer, *opers|
	if answer.is_a?(String) and answer =~ /^\d+$/
		answer = answer.to_i.to_en
	elsif answer.is_a?(Integer)
		answer = answer.to_en
	end
	answer == opers.inject { |sum, var| sum + var }.to_en
end
