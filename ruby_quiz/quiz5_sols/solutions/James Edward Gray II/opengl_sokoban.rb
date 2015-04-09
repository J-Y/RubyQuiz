#!/usr/bin/env ruby

require "opengl"
require "glut"

require "sokoban"

PATH = File.expand_path(File.dirname(__FILE__))

def init
	GL.Light GL::LIGHT0, GL::AMBIENT, [0.0, 0.0, 0.0, 1.0]
	GL.Light GL::LIGHT0, GL::DIFFUSE, [1.0, 1.0, 1.0, 1.0]
	GL.Light GL::LIGHT0, GL::POSITION, [0.0, 3.0, 3.0, 0.0]
	GL.LightModel GL::LIGHT_MODEL_AMBIENT, [0.2, 0.2, 0.2, 1.0]
	GL.LightModel GL::LIGHT_MODEL_LOCAL_VIEWER, [0.0]
	
	GL.FrontFace GL::CW
	GL.Enable GL::LIGHTING
	GL.Enable GL::LIGHT0
	GL.Enable GL::AUTO_NORMAL
	GL.Enable GL::NORMALIZE
	GL.Enable GL::DEPTH_TEST
	GL.DepthFunc GL::LESS
end

def render_man
	GL.Material GL::FRONT, GL::AMBIENT, [0.0, 0.0, 0.0, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [0.5, 0.0, 0.0, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.7, 0.6, 0.6, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.25 * 128.0
	
	GLUT.SolidSphere 0.5, 16, 16
end

def render_crate
	GL.Material GL::FRONT, GL::AMBIENT, [0.19125, 0.0735, 0.0225, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [0.7038, 0.27048, 0.0828, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.256777, 0.137622, 0.086014, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.1 * 128.0
	
	GL.PushMatrix
		GL.Scale 0.9, 0.9, 0.9
		GL.Translate 0.0, 0.0, 0.45
		
		GLUT.SolidCube 1.0
	GL.PopMatrix
end

def render_stored_crate
	GL.Material GL::FRONT, GL::AMBIENT, [0.25, 0.20725, 0.20725, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [1.0, 0.829, 0.829, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.296648, 0.296648, 0.296648, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.088 * 128.0
	
	GL.PushMatrix
		GL.Scale 0.9, 0.9, 0.9
		GL.Translate 0.0, 0.0, 0.45
		
		GLUT.SolidCube 1.0
	GL.PopMatrix
end

def render_open_floor
	GL.Material GL::FRONT, GL::AMBIENT, [0.05, 0.05, 0.05, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [0.5, 0.5, 0.5, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.7, 0.7, 0.7, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.078125 * 128.0
	
	GL.PushMatrix
		GL.Scale 0.9, 0.9, 0.1
		GL.Translate 0.0, 0.0, -0.05
		
		GLUT.SolidCube 1.0
	GL.PopMatrix

	GL.Material GL::FRONT, GL::AMBIENT, [0.05375, 0.05, 0.06625, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [0.18275, 0.17, 0.22525, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.332741, 0.328634, 0.346435, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.3 * 128.0

	GL.PushMatrix
		GL.Scale 1.0, 1.0, 0.1
		GL.Translate 0.0, 0.0, -0.1
		
		GLUT.SolidCube 1.0
	GL.PopMatrix
end

def render_storage
	GL.Material GL::FRONT, GL::AMBIENT, [0.05, 0.05, 0.0, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [0.5, 0.5, 0.4, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.7, 0.7, 0.04, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.078125 * 128.0
	
	GL.PushMatrix
		GL.Scale 0.9, 0.9, 0.1
		GL.Translate 0.0, 0.0, -0.05
		
		GLUT.SolidCube 1.0
	GL.PopMatrix

	GL.Material GL::FRONT, GL::AMBIENT, [0.05375, 0.05, 0.06625, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [0.18275, 0.17, 0.22525, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.332741, 0.328634, 0.346435, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.3 * 128.0

	GL.PushMatrix
		GL.Scale 1.0, 1.0, 0.1
		GL.Translate 0.0, 0.0, -0.1
		
		GLUT.SolidCube 1.0
	GL.PopMatrix
end

def solid_cylinder(radius, height, slices, stacks) 
	GL.PushAttrib GL::POLYGON_BIT
		GL.PolygonMode GL::FRONT_AND_BACK, GL::FILL
		obj = GLU.NewQuadric
		GLU.Cylinder obj, radius, radius, height, slices, stacks
		GL.PushMatrix
			GL.Translate 0.0, 0.0, height
			GLU.Disk obj, 0.0, radius, slices, stacks
		GL.PopMatrix
		GLU.DeleteQuadric obj 
	GL.PopAttrib
end 

def render_wall
	GL.Material GL::FRONT, GL::AMBIENT, [0.0, 0.0, 0.0, 1.0]
	GL.Material GL::FRONT, GL::DIFFUSE, [0.1, 0.35, 0.1, 1.0]
	GL.Material GL::FRONT, GL::SPECULAR, [0.45, 0.55, 0.45, 1.0]
	GL.Material GL::FRONT, GL::SHININESS, 0.25 * 128.0
	
	GL.PushMatrix
		GL.Translate 0.0, 0.0, 0.5
		
		solid_cylinder 0.45, 1.0, 16, 4
	GL.PopMatrix
end

game = Sokoban.new

display = lambda do
	GL.Clear GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT

	screen = game.display
	screen.each_with_index do |row, y|
		row.chomp!
		first = row =~ /^(\s+)/ ? $1.length : 0
		(first...row.length).each do |x|
			GL.PushMatrix
				GL.Translate 1.0 + x, 17.5 - y, 0.0
				
				if row[x, 1] == "." or row[x, 1] == "*" or row[x, 1] == "+"
					render_storage
				else
					render_open_floor
				end
				if row[x, 1] == "@" or row[x, 1] == "+"
					render_man
				elsif row[x, 1] == "o"
					render_crate
				elsif row[x, 1] == "*"
					render_stored_crate
				elsif row[x, 1] == "#"
					render_wall
				end
			GL.PopMatrix
		end
	end

	GL.Flush
end

reshape = lambda do |w, h|
	GL.Viewport 0, 0, w, h
	GL.MatrixMode GL::PROJECTION
	GL.LoadIdentity
	GL.Frustum(-1.0, 1.0, -1.0, 1.0, 1.5, 20.0)
	GL.MatrixMode GL::MODELVIEW
	GLU.LookAt 10.0, 10.0, 17.5, 10.0, 10.0, 0.0, 0.0, 1.0, 0.0
end

keyboard = lambda do |key, x, y|
	case key
		when ?Q, ?\C-c
			exit 0
		when ?S
			game.save
		when ?L
			if test ?e, File.join(PATH, "sokoban_saved_game.yaml")
				game = Sokoban.load 
			end
		when ?R
			game.restart_level
		when ?N
			game.load_level
		when ?U
			game.undo
		when ?j, ?j
			game.move_left
		when ?k, ?K
			game.move_right
		when ?m, ?m
			game.move_down
		when ?i, ?I
			game.move_up
	end

	if game.level_solved?
		game.load_level

		exit 0 if game.over?
	end
	
	GLUT.PostRedisplay
end

GLUT.Init
GLUT.InitDisplayMode GLUT::SINGLE | GLUT::RGB | GLUT::DEPTH
GLUT.CreateWindow "Sokoban"

init

GLUT.KeyboardFunc keyboard
GLUT.ReshapeFunc reshape
GLUT.DisplayFunc display

GLUT.MainLoop
