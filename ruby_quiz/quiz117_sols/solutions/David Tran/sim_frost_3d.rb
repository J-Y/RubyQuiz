# Quiz 117 : SimFrost3D
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

	#Standard initializer. It prepares the windows to be called.
	def initialize
		
		$WIDTH = ARGV[0] && ARGV[0].to_i || 100
		$HEIGHT = ARGV[1] && ARGV[1].to_i || 100
		$DEPTH = ARGV[2] && ARGV[2].to_i || 100
		
		$WIDTH += 1 if $WIDTH % 2 != 0
		$HEIGHT += 1 if $HEIGHT % 2 != 0
		$DEPTH += 1 if $DEPTH % 2 != 0
		
		$DENSITY = ARGV[2] && ARGV[2].to_i || 30
		
		$VAPOR = 0
		
		make_matrix
		
		#We set the center to be frozen
		#We set the center to be frozen
		x = $GRID[$HEIGHT/2][$WIDTH/2][$DEPTH/2]
		$VAPOR -= 1 if x != nil and x.element == :vapor
		$GRID[$HEIGHT/2][$WIDTH/2][$DEPTH/2] = Element.new(:ice)
		
		$TICK_COUNT = 0
		#Standard GL methods
		GLUT.Init
		GLUT.InitDisplayMode(GLUT::DOUBLE)
		GLUT.InitWindowSize($WIDTH*5, $HEIGHT*5)
		GLUT.InitWindowPosition(100, 100)
		GLUT.CreateWindow('SimFrost3D : Quiz #117 - by CHubas')
		GL.ShadeModel(GL::SMOOTH)
		light
		GLUT.DisplayFunc(method(:display).to_proc)
		GLUT.KeyboardFunc(method(:keyboard).to_proc)
		GLUT.ReshapeFunc(method(:reshape).to_proc)
		
		# IdleFunc takes a proc object and calls it continously whenever it can.
		GLUT.IdleFunc(method(:tick).to_proc)
	end
	
	def light
		
		
		$no_mat = [ 0.0, 0.0, 0.0, 1.0 ]
		$ice_color = [ 0.5, 0.8, 0.9, 1.0 ]
		$vapor_color = [ 0.0, 0.5, 1.0, 1.0 ]
		
		ambient = [ 0.5, 0.5, 1.0, 1.0 ]
		position = [ 10.0, 10.0, 2.0, 0.0 ]
		lmodel_ambient = [ 0.4, 0.4, 0.4, 1.0 ]
		local_view = [ 0.0 ]
		
		GL::Light(GL::LIGHT0, GL::AMBIENT, ambient);
		GL::Light(GL::LIGHT0, GL::POSITION, position);
		GL::LightModel(GL::LIGHT_MODEL_AMBIENT, lmodel_ambient);
		GL::LightModel(GL::LIGHT_MODEL_LOCAL_VIEWER, local_view);
		GL::Enable(GL::LIGHTING);
		GL::Enable(GL::LIGHT0);

	end
	
	# Here we create the pixel information.
	# Open GL takes an array of integers and splits it in groups of three
	# that represent one color component each.
	def make_matrix
		# We create a matrix, assigning randomly (according to the
		# percentage) the density of vapor. Vacuum is represented by nil.
		$GRID = Array.new($HEIGHT) do
			Array.new($WIDTH) do
				Array.new($DEPTH) do
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
		end
	end

	# Some basic window behavior
	def reshape(w, h)
		GL.Viewport(0, 0, w, h)
		GL.MatrixMode(GL::PROJECTION)
		GL.LoadIdentity()
		GL.Ortho(-($WIDTH*2.0), $WIDTH*2.0, -($HEIGHT*2.0), $HEIGHT*2.0, -($DEPTH*2.0), $DEPTH*2.0)
		GL.MatrixMode(GL::MODELVIEW)
		GL.LoadIdentity()
		GL.Rotate(30, 5.0, 1.0, 1.0)
		#GLU.LookAt(0.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
	end
	
	def keyboard(key, x, y)
		case (key)
			when 27
				exit(0)
			when ?k
				GL.Rotate(10, 1.0, 0.0, 0.0)
			when ?K
				GL.Rotate(-10, 1.0, 0.0, 0.0)
			when ?i
				GL.Rotate(10, 0.0, 0.0, 1.0)
			when ?I
				GL.Rotate(-10, 0.0, 0.0, 1.0)
			when ?j
				GL.Rotate(10, 0.0, 1.0, 0.0)
			when ?l
				GL.Rotate(-10, 0.0, -1.0, 0.0)
			when ?z
				GL.Translate(0.0, 0.0, 0.0)
		end
	end
	
	# Draws the pixel bitmap
	def display
		GL.Clear(GL::COLOR_BUFFER_BIT);
		
		#GLU.LookAt($x, $y, $z, 10.0, 0.0, 0.0, 0.0, 1.0, 0.0)
		
		for i in 0...$HEIGHT
			for j in 0...$WIDTH
				for k in 0...$DEPTH
					particle = $GRID[i][j][k]
					
					next unless particle
					
					pos_x = (i - $HEIGHT/2) * 2.0
					pos_y = (j - $WIDTH/2) * 2.0
					pos_z = (k - $DEPTH/2) * 2.0
					GL::PushMatrix()
					GL::Translate(pos_x, pos_y, pos_z)
					
					if particle.element == :vapor
							GL::Material(GL::FRONT, GL::AMBIENT, $vapor_color);
							GL::Material(GL::FRONT, GL::SHININESS, [0.2]);
					else
							GL::Translate(pos_x, pos_y, pos_z);
							GL::Material(GL::FRONT, GL::AMBIENT, $ice_color);
							GL::Material(GL::FRONT, GL::SHININESS,[0.2]);
							GL::Material(GL::FRONT, GL::EMISSION, $no_mat);
					end
					
					GLUT::SolidCube(2);
					GL::PopMatrix();
				end
				
			end
		end
		
		GLUT.PostRedisplay
		GLUT.SwapBuffers
		GL.Flush
	end
	
	def iterate_cubes( tick_number )
		start = 0
		w_end = $WIDTH
		h_end = $HEIGHT
		d_end = $DEPTH
		
		if tick_number % 2 != 0 #odd
			start -= 1
			w_end -= 1
			h_end -= 1
			d_end -= 1
		end
		
		(start...h_end).step(2) do |row|
			(start...w_end).step(2) do |column|
				(start...d_end).step(2) do |depth|
					cube = get_cube_at(row, column, depth)
					if cube.any?{|e| e != nil && e.element == :ice}
						for e in cube
							next if e.nil?
							e.freeze
						end
					else
						cube = rotate(cube)
					end
					set_cube_at(row, column, depth, cube)
				end
			end
		end
		
	end
	
	def tick
		iterate_cubes( ($TICK_COUNT += 1) )
		
		#Stop doing this if everything is frozen already
		if all_frozen?
			GLUT.IdleFunc(nil)
		end
	end

	def get_cube_at(row, column, depth)
		[
			$GRID[row][column][depth],$GRID[row][column+1][depth],
			$GRID[row+1][column][depth],$GRID[row+1][column+1][depth],
			$GRID[row][column][depth+1],$GRID[row][column+1][depth+1],
			$GRID[row+1][column][depth+1],$GRID[row+1][column+1][depth+1],
		]
	end

	def set_cube_at(row, column, depth, new_cube)
		$GRID[row][column][depth],$GRID[row][column+1][depth],
		$GRID[row+1][column][depth],$GRID[row+1][column+1][depth],
		$GRID[row][column][depth+1],$GRID[row][column+1][depth+1],
		$GRID[row+1][column][depth+1],$GRID[row+1][column+1][depth+1] = new_cube
	end

	def rotate(cube)
		if rand > 0.5
			cube.values_at(1,5,3,7,0,4,2,6)
		else
			cube.values_at(2,3,6,7,0,1,4,5)
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