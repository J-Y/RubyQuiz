#!/usr/bin/ruby -w

class Fractal
	
	def initialize n
		@steps={:up =>[:up, :left, :up, :right, :up],
			:down=>[:down, :right, :down, :left, :down],
			:left=>[:left, :down, :left, :up, :left],
			:right=>[:right, :up, :right, :down, :right] }
		@n=n
		@moves=(0..n).to_a.inject([]) {|result, ignore| one_step(result) }
	end
	
	def to_s
		x=0
		y=0
		
		width = 3 ** @n
		height= (1+width)/2
		screen= (1.. height).collect { " " *(2* width-1) } 
		
		@moves.each {|item| 
			case item 
				when :up
					y+=1
					(screen[y-1])[x-1]="|"
				when :down
					y-=1
					(screen[y])[x-1]="|"
				when :left
					x-=2
					(screen[y])[x]="_"
				when :right
					x+=2
					(screen[y])[x-2]="_"
			end
		}
		screen.reverse.join("\n")
	end

	private
	
	def one_step x
		x.empty? ? [:right] : (x.collect {|item| @steps[item] }).flatten
	end
	
end

n=ARGV[0].to_i

if (ARGV.length < 1 || n<0) 
	puts "Usage: quizz_125.rb level"
	puts "-> level: non-negative integer"
else
	puts Fractal.new(n)
end
