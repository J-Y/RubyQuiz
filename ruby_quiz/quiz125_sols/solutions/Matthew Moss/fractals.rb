class LSystem

	def initialize(&block)
		@rules = {}
		instance_eval(&block)
	end

	def rule(var)
		raise "Rule for #{var} must be unique!" if @rules.include?(var.to_sym)
		@rules[var.to_sym] = yield.map { |x| x.to_sym }
	end

	def start(var)
		@start = var.to_sym
	end

	def evaluate(n)
		product = [@start]
		n.to_i.times do |i|
			product.map! do |s|
				@rules[s.to_sym] || s.to_sym
			end.flatten!
		end

		product.each do |p|
			send(p)
		end
	end

end


koch = LSystem.new do
	start :F
	rule(:F) { %w(F + F - F - F + F) }

	
	def F
		nx, ny = @x + @dx, @y + @dy
		puts <<-LINE
<line x1="#{@x}" y1="#{@y}" x2="#{nx}" y2="#{ny}" stroke="black" />
		LINE
		@x, @y = nx, ny
	end

	def +
		@dx, @dy = -@dy, @dx
	end

	def -
		@dx, @dy = @dy, -@dx
	end

	def evaluate(n)
		raise "N must be non-negative" if n < 0
		@x,  @y =  0, 0
		@dx, @dy = 900 / (3 ** n), 0

		puts <<-HEADER
<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
	"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve"
	width="900px" height="450px" viewBox="0 0 900 450" >
		HEADER

		super
		
		puts <<-FOOTER
</svg>
		FOOTER
	end
end


koch.evaluate(ARGV[0].to_i)
