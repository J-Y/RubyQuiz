# Quiz 117 : SimFrost
# Ruben Medellin <chubas7@gmail.com>

#Based on OpenGL
require 'opengl'
require 'glut'

# Each pixel represents an element.
class Element

	attr_accessor :element
	
	def initialize(element)
		@element = element
	end
	
	#Just a change of state. Don't forget to decrement the vapor number.
	def freeze
		if  @element == :vapor
			$VAPOR -= 1
			@element = :ice
		end
	end

end

# Main class
class Freeze_Simulator
	
	def make_grid
		# We create a matrix, assigning randomly (according to the
		# percentage) the density of vapor. Vacuum is represented by nil.
		$VAPOR = 0
		
		$GRID = Array.new($HEIGHT) do
			Array.new($WIDTH) do
				if rand(100) > $DENSITY
					nil
				else
					# We need this counter if we want a nice quick
					# checker for all_frozen? method
					$VAPOR += 1
					Element.new(:vapor)
				end
			end
		end
		
		#We set the center to be frozen
		x = $GRID[$HEIGHT/2][$WIDTH/2]
		$VAPOR -= 1 if x != nil and x.element == :vapor
		$GRID[$HEIGHT/2][$WIDTH/2] = Element.new(:ice)
		
		$TICK_COUNT = 0
	end
	
	#Standard initializer. It prepares the windows to be called.
	def initialize
		
		$WIDTH = ARGV[0] && ARGV[0].to_i || 100
		$HEIGHT = ARGV[1] && ARGV[1].to_i || 100
		
		$WIDTH += 1 if $WIDTH % 2 != 0
		$HEIGHT += 1 if $HEIGHT % 2 != 0
		
		$DENSITY = ARGV[2] && ARGV[2].to_i || 30
		
		make_grid
		
		
		
		#Standard GL methods
		GLUT.Init
		GLUT.InitDisplayMode(GLUT::DOUBLE)
		GLUT.InitWindowSize($WIDTH*2, $HEIGHT*2)
		GLUT.InitWindowPosition(100, 100)
		GLUT.CreateWindow('SimFrost : Quiz #117 - by CHubas')
		GL.ShadeModel(GL::FLAT)
		GL.PointSize(2.0)
		GLUT.DisplayFunc(method(:display).to_proc)
		GLUT.KeyboardFunc(Proc.new{|k, x, y| exit if k == 27})
		GLUT.ReshapeFunc(method(:reshape).to_proc)
		
		# IdleFunc takes a proc object and calls it continously whenever it can.
		GLUT.IdleFunc(method(:tick).to_proc)
	end

	# Some basic window behavior
	def reshape(w, h)
		GL.Viewport(0, 0, w, h)
		GL.MatrixMode(GL::PROJECTION)
		GL.LoadIdentity()
		GL.Ortho(-$WIDTH, $WIDTH, -$HEIGHT, $HEIGHT, -1.0, 1.0)
		GL.MatrixMode(GL::MODELVIEW)
		
		#GLU.LookAt(-5.0, -5.0, -10.0, 10.0, 0.0, 0.0, 0.0, 1.0, 0.0)
		
	end
	
	# Draws the pixel bitmap
	def display
		GL.Clear(GL::COLOR_BUFFER_BIT);   
		GL.Begin(GL::POINTS)
		
		for i in 0...$HEIGHT
			for j in 0...$WIDTH
				particle = $GRID[i][j]
				next unless particle
				if particle.element == :vapor
					GL.Color(0.5, 0.5, 1.0)
				else
					GL.Color(1.0, 1.0, 1.0)
				end
				GL.Vertex3f((i - $HEIGHT/2) * 2.0, (j - $WIDTH/2) * 2.0, 0.0)
			end
		end
	
		GL.End
	end

	# We split the board into 2*2 squares with this method
	def iterate_squares( tick_number )
		start = 0
		w_end = $WIDTH
		h_end = $HEIGHT
		
		if tick_number % 2 != 0 #odd
			start -= 1
			w_end -= 1
			h_end -= 1
		end
		
		(start...h_end).step(2) do |row|
			(start...w_end).step(2) do |column|
				square = get_square_at(row, column)
				if square.any?{|e| e != nil && e.element == :ice}
					for e in square
						next if e.nil?
						e.freeze
					end
				else
					square = rotate(square)
				end
				set_square_at(row, column, square)
			end
		end
		
	end
	
	# Checks for each 2*2 square and does the proper transformation
	def tick
		iterate_squares( ($TICK_COUNT += 1) )
		
		# Having modified the matrix, now we have to rebuild the pixel map
		GLUT.PostRedisplay
		GLUT.SwapBuffers
		#Stop doing this if everything is frozen already
		if all_frozen?
			GLUT.IdleFunc(nil)
		end
	end

	# Some dirty methods
	def get_square_at(row, column)
		[$GRID[row][column],$GRID[row][column+1],$GRID[row+1][column],$GRID[row+1][column+1]]
	end

	def set_square_at(row, column, new_square)
		$GRID[row][column],$GRID[row][column+1],$GRID[row+1][column],$GRID[row+1][column+1] = new_square
	end
	
	# Rotates elements in
	# | 0 1 |
	# | 2 3 |
	def rotate(square)
		if rand(2) == 0
			square.values_at(1,3,0,2)
		else
			square.values_at(2,0,3,1)
		end
	end
	
	# Validates if there is any vapor particle
	def all_frozen?
		if $VAPOR > 0
			return false
		else
			puts "Welcome to the ice age!"
			puts "All frozen in #{$TICK_COUNT} thicks"
			return true
		end
	end
	
	# Starts the main loop
	def start
		GLUT.MainLoop
	end
	
end

#Let the fun begin
Freeze_Simulator.new.start