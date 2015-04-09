# Class that takes numbers and transforms them into a symbol
# specified for the user

class UselessSoundMaker

	attr_accessor :sounds

	def initialize(args)
		@sounds = args
	end

	def add_sounds(args)
		@sounds.update(args)
	end

	def display(range = 1..100)
		for number in range
			if (multiples = @sounds.keys.select{|m| number % m == 0}).empty?
				puts number
			else
				puts multiples.sort.collect{|m| @sounds[m]}.join
			end
		end
	end

end

fizzbuzz = UselessSoundMaker.new(3 => 'Fizz', 5 => 'Buzz')
fizzbuzz.display

foobar = UselessSoundMaker.new(3 => 'Foo', 4 => 'Bar', 5 => 'Baz')
foobar.display(1..50)

beepbeep = UselessSoundMaker.new(10 => "\a")
beepbeep.display(1..100)
