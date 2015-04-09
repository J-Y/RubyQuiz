require "opengl"
require "glut"
require "mathn"
require "geodesic"
require 'matrix'
require 'geodesic-data'

# Change these settings
frequency = 5
primitive = :octahedron

# create the geodesic dome
geo = GeoDesicDome.new
$triangles = geo.subsample(PRIMITIVES[primitive], frequency)

$spin = 0.0

# Initialize linear fog for depth cueing.
def myinit
	fogColor = [0.0, 0.0, 0.0, 1.0];
	
	GL.Enable(GL::FOG);
	GL.Fog(GL::FOG_MODE, GL::LINEAR);
	GL.Hint(GL::FOG_HINT, GL::NICEST);
	GL.Fog(GL::FOG_START, 3.0);
	GL.Fog(GL::FOG_END, 5.0);
	GL.Fog(GL::FOG_COLOR, fogColor);
	GL.ClearColor(0.0, 0.0, 0.0, 1.0);
	
	GL.DepthFunc(GL::LESS);
	GL.Enable(GL::DEPTH_TEST);
	GL.ShadeModel(GL::FLAT);
end

# idle-func
spinDisplay = Proc.new {
	$spin = $spin + 1.0;
	sleep 0.01
	GLUT.PostRedisplay();
}

# display draws all triangles
display = Proc.new {
	GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT);
	GL.Color(1.0, 1.0, 1.0);
	GL.PushMatrix()
	
	# just do some random rotation
	GL.Rotate($spin, $spin*0.132, $spin*0.3213, 1.0);
	
	$triangles.each do |a, b, c|
		drawTriangle a, b, c
	end
	GL.PopMatrix()
	GL.Flush();
	GLUT.SwapBuffers();
}

# draw one triangle
def drawTriangle(a, b, c)
	GL::Begin GL::LINE_LOOP
	GL::Vertex a[0], a[1], a[2]
	GL::Vertex b[0], b[1], b[2]
	GL::Vertex c[0], c[1], c[2]
	GL::End()
end

myReshape = Proc.new {|w, h|
	GL.Viewport(0, 0, w, h);
	GL.MatrixMode(GL::PROJECTION);
	GL.LoadIdentity();
	GLU.Perspective(45.0,  w/h, 3.0, 5.0);
	GL.MatrixMode(GL::MODELVIEW);
	GL.LoadIdentity();
	GL.Translate(0.0, 0.0, -4.0);  #/*  move object into view   */
}

# Main Loop
GLUT.Init
GLUT.InitDisplayMode(GLUT::DOUBLE | GLUT::RGB | GLUT::DEPTH);
GLUT.CreateWindow($0);
myinit();
GLUT.ReshapeFunc(myReshape);
GLUT.DisplayFunc(display);
GLUT.IdleFunc(spinDisplay)
GLUT.MainLoop();
