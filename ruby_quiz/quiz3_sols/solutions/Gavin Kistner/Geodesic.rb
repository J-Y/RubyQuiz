#--
# *** This code is copyright 2004 by Gavin Kistner
# *** It is covered under the license viewable at http://phrogz.net/JS/_ReuseLicense.txt
# *** Reuse or modification is free provided you abide by the terms of that license.
# *** (Including the first two lines above in your source code usually satisfies the conditions.)
#++
# This file houses the Geodesic class, allowing you to create a Geodesic dome/sphere based on a tetrahedron or octahedron. See the Geodesic class for more information.
#
# Author::     Gavin Kistner  (mailto:gavin@refinery.com)
# Copyright::  Copyright (c)2004 Gavin Kistner
# License::    See http://Phrogz.net/JS/_ReuseLicense.txt for details
# Version::    1.5
# Full Code::  link:../Geodesic.rb

# Version History
# 20040916  v1.0    Initial Release
# 20040917  v1.0.5  Better spacing of faces (normalize points at the end, not during recursion)
# 20040920  v1.1    Added :icosahedron
# 20041010  v1.5    Rewrote to use new frequency derivation

require 'matrix.rb'

# Represents a Geodesic dome/sphere; the object is comprised of an array of Face instances, each specified in counter-clockwise order.
class Geodesic

	# Represents a triplet of Vectors defining a face
	class Face
		attr_reader :a, :b, :c
		def initialize( *pts )
			@a, @b, @c = *pts.flatten
		end
		def points
			[ @a, @b, @c ]
		end
		
		# Reverse the direction of the face's normal
		# by swapping the first and last points
		def reverse!
			@a, @c = @c, @a
		end
		
		# Scale each point by the specified factor
		def scale_by( scale_factor )
			points.each{ |p| p.scale_by!( scale_factor ) }
		end
		
		def to_s
			"<Geodesic::Face @points=[ #@a, #@b, #@c ]>"
		end
		
		# Subdivide the face into <tt>(frequency+1)^2</tt> sub-triangles
		#
		# Returns an array of new Face instances
		#
		# Note that the points shared by common faces will be pointers to the same vector instance
		def subdivide_by( frequency=0 )
			@sub_freq = frequency
			@sub_x_offset = (@b-@c) / (frequency+1)
			@sub_y_offset = (@a-@c) / (frequency+1)
			
			@sub_faces = []
			@sub_points = {}
			_sub_process_hex( 0, 0 )
			@sub_points.each_value{ |v| v.normalize! }
			@sub_faces
		end
		
		# Return the normal of this face
		def normal
			(@a-@b).cross(@c-@b)
		end
		
		# Returns +true+ if the normal of the face points away from the origin
		def normal_out?
			self.normal.dot( @a ) > 0
		end
		
		private
		#--
			def _sub_process_hex( x_steps, y_steps )
				return if _sub_seen_point? x_steps, y_steps
		
				#skip this hexagon if the center isn't in bounds
				hex_center = _sub_point_at( x_steps, y_steps )
				return unless hex_center
				
				# Find the 6 points around the hexagon
				p1 = _sub_point_at( x_steps+1, y_steps   )
				p2 = _sub_point_at( x_steps,   y_steps+1 )
				p3 = _sub_point_at( x_steps-1, y_steps+1 )
				p4 = _sub_point_at( x_steps-1, y_steps   )
				p5 = _sub_point_at( x_steps,   y_steps-1 )
				p6 = _sub_point_at( x_steps+1, y_steps-1 )
		
				# Add the six triangles in the hexagon as faces
				# but only if all points for the face are in bounds 
				@sub_faces << Face.new( p1, p6, hex_center ) if p1 && p6
				@sub_faces << Face.new( p2, p1, hex_center ) if p2 && p1
				@sub_faces << Face.new( p3, p2, hex_center ) if p3 && p2
				@sub_faces << Face.new( p4, p3, hex_center ) if p4 && p3
				@sub_faces << Face.new( p5, p4, hex_center ) if p5 && p4
				@sub_faces << Face.new( p6, p5, hex_center ) if p6 && p5
				
				# Process the 3 hexagons 'out' from this one
				_sub_process_hex( x_steps+3, y_steps   )
				_sub_process_hex( x_steps+1, y_steps+1 )
				_sub_process_hex( x_steps,   y_steps+3 )
			end

			# Returns the Vector if the point referenced by the step
			# offsets has already been visited/created; nil otherwise
			def _sub_seen_point?( x_steps, y_steps )
				@sub_points[ [ x_steps, y_steps ] ]
			end

			# Adds/returns the Vector object corresponding to the
			# x/y offset steps from point c; nil if out of bounds
			def _sub_point_at( x_steps, y_steps )
				return nil unless _sub_in_bounds?( x_steps, y_steps )
				@sub_points[ [x_steps, y_steps] ] ||= @c + @sub_x_offset * x_steps + @sub_y_offset * y_steps
			end

			# Returns true if the point referenced by the step offsets
			# is in bounds for the overall face; false otherwise
			def _sub_in_bounds?( x_steps, y_steps )
				x_steps >= 0 && y_steps >= 0 && (x_steps + y_steps) <= (@sub_freq+1)
			end
		#++
	end

	SQRT2 = Math.sqrt(2)
	SQRT3 = Math.sqrt(3)
	
	TETRA_Q = SQRT2 / 3
	TETRA_R = 1.0 / 3
	TETRA_S = SQRT2 / SQRT3
	TETRA_T = 2 * SQRT2 / 3

	GOLDEN_MEAN = (Math.sqrt(5)+1)/2
	
	PRIMITIVES = {
		:tetrahedron => {
			:points => {
				:a => Vector[ -TETRA_S, -TETRA_Q, -TETRA_R ],
				:b => Vector[  TETRA_S, -TETRA_Q, -TETRA_R ],
				:c => Vector[        0,  TETRA_T, -TETRA_R ],
				:d => Vector[        0,        0,        1 ]
			},
			:faces => %w| acb abd adc dbc |
		},
		:octahedron => {
			:points => {
				:a => Vector[  0,  0,  1],
				:b => Vector[  1,  0,  0],
				:c => Vector[  0, -1,  0],
				:d => Vector[ -1,  0,  0],
				:e => Vector[  0,  1,  0],
				:f => Vector[  0,  0, -1]
			},
			:faces => %w| cba dca eda bea
			              def ebf bcf cdf |
		},
		:icosahedron => {
			:points => {
				:a => Vector[  1,  GOLDEN_MEAN, 0 ],
				:b => Vector[  1, -GOLDEN_MEAN, 0 ],
				:c => Vector[ -1, -GOLDEN_MEAN, 0 ],
				:d => Vector[ -1,  GOLDEN_MEAN, 0 ],
				:e => Vector[  GOLDEN_MEAN, 0,  1 ],
				:f => Vector[ -GOLDEN_MEAN, 0,  1 ],
				:g => Vector[ -GOLDEN_MEAN, 0, -1 ],
				:h => Vector[  GOLDEN_MEAN, 0, -1 ],
				:i => Vector[ 0,  1,  GOLDEN_MEAN ],
				:j => Vector[ 0,  1, -GOLDEN_MEAN ],
				:k => Vector[ 0, -1, -GOLDEN_MEAN ],
				:l => Vector[ 0, -1,  GOLDEN_MEAN ]

			},
			:faces => %w| iea iad idf ifl ile
			              eha ajd dgf fcl lbe
			              ebh ahj djg fgc lcb
			              khb kjh kgj kcg kbc |
		}
	}
	
	# Change each primitive to simply be an array of faces,
	# using and removing the :points and :faces information
	PRIMITIVES.each_pair{ |primitive, pf|
		PRIMITIVES[primitive] = pf[:faces].collect{ |pts|
			Face.new( pts.split('').collect{ |pt_name|
				pf[:points][pt_name.to_sym]
			} )
		}
	}

	# Returns the array of Face instances representing the Geodesic.
	attr_reader :faces

	# Gets/sets the radius of the Geodesic, scaling the vertices on every face.
	attr_accessor :radius

	# Creates a new Geodesic dome/sphere of specified radius about the origin.
	# _frequency_::  The number of times to subdivide each face of the primitive; a frequency of <tt>0</tt> yields the primitive itself. Defaults to <tt>1</tt>.
	# _primitive_::  The type of primitive to use as a basis for the geodesic. May be one of <tt>:tetrahedron</tt>, <tt>:octahedron</tt>, or <tt>:icosahedron</tt>. Defaults to <tt>:octahedron</tt>.
	# _radius_::     An initial radius for the geodesic. Defaults to <tt>1</tt>.
	#
	# The number of faces in the Geodesic is <tt>(faces in primitive) * (frequency+1)^2</tt>:
	#  freq  tetra  octa  icosa
	#     0      4     8     20
	#     1     16    32     80
	#     2     36    72    180
	#     3     64   128    320
	#     4    100   200    500
	#     5    144   288    720
	#     6    196   392    980
	#     7    256   512   1280
	#     8    324   648   1620
	#     9    400   800   2000
	#    10    484   968   2420
	#    11    576  1152   2880
	#    12    676  1352   3380
	#    13    784  1568   3920
	#    14    900  1800   4500
	#    15   1024  2048   5120
	#    16   1156  2312   5780
	#    17   1296  2592   6480
	#    18   1444  2888   7220
	#    19   1600  3200   8000
	#     :     :     :     :
	#
    # For this reason, you should take care not to specify an overly-large +frequency+ value. The following graphic gives a visual depiction of the frequency value:
    #
    # link:../Geodesics.png.
	def initialize( frequency = 1, primitive = :octahedron, radius = 1 )
		raise "The Geodesic class does not support the primitive type '#{primitive}'" unless PRIMITIVES[primitive]
		@faces = PRIMITIVES[primitive].dup
		if frequency > 0
			@faces.collect!{ |face|
				face.subdivide_by( frequency )
			}.flatten!
		end
		@radius = 1
		self.radius = radius
	end

	def radius=( r ) #:nodoc:
		return if r==@radius
		all_points = @faces.collect{ |face| face.points }.flatten!
		all_points.uniq!
		all_points.each{ |v| v.r = r }
		@radius = r
	end
end

# Extensions to the Vector class
class Vector
	# Returns a Vector whose length (<tt>.r</tt>) is 1.0
	def normalized
		self / self.r
	end

	# Modify the receiving vector to be of length (<tt>.r</tt>) 1.0 
	def normalize!
		len = self.r
		self.scale_by!( 1/len )
	end

	# Modify the receiving vector, multiplying each component by the specified factor
	def scale_by!( scale_factor )
		@elements.collect!{ |e| e*scale_factor }
		self
	end
	
	# Modify the receiving vector, scaling it to be the specified length
	def r=(new_len)
		old_len = self.r
		self.scale_by!( new_len/old_len ) unless new_len==old_len
		self
	end
	
	# Divide the vector by a scalar
	# Scales the values in the Vector by 1.0 / n, and returns the new Vector
	def /( n )
		self * ( 1.0 / n )
	end
	
	# Returns the cross product of two 3D vectors
	def cross( v2 )
		raise "v1 & v2 only applicable to 3D vectors" unless self.size==3 && v2.size==3
		ax = self[0]; ay = self[1]; az = self[2]
		bx = v2[0];   by = v2[1];   bz = v2[2]
		Vector[
			ay * bz - by * az,
			az * bx - bz * ax,
			ax * by - bx * ay
		]
	end
	
	alias_method :dot, :inner_product
end