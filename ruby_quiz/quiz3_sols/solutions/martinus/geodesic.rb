# Creates a geodesic dome from primitives as described in ruby quiz #3
class GeoDesicDome
	# Create a geodesic dome for a given primitive
	def subsample(primitive, freq)
		triangles = []
		primitive[:faces].each do |face|
			# get array of points from letters (like, "abc" -> Array with point a, point b, and point c).
			originalTriangle = face.scan(/./).collect { |letter| primitive[:points][letter] }
			triangles += subsample3(freq, *originalTriangle)
		end
		triangles
	end

	private
	# Split a line  through a and b by freq points, 
	# Return an array of the resulting points
	def split(freq, a, b)
		ab = []
		(freq+2).times do |f|
			x = 1.0*f / (freq+1)
			ab.push b*x + a*(1.0-x)
		end
		ab
	end

	# Create a geodesic dome for the triangle defined by a, b, c.
	# Return an array containing triangles (triangle = array of 3 cartesian 3-space points)
	def subsample3(freq, a, b, c)
		faces = []
		ab = split(freq, a, b)
		ac = split(freq, a, c)
	
		prevLine = [ ab[0] ]
		(freq+1).times do |f|
			nextLine = split(f, ab[f+1], ac[f+1])
			prevLine.each_index do |i|
				faces.push [nextLine[i], nextLine[i+1], prevLine[i]]
				faces.push [prevLine[i], prevLine[i+1], nextLine[i+1]] if i+1<prevLine.size
			end
			prevLine = nextLine
		end
		faces
	end
end
