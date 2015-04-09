class Vector
  include Math

  attr_reader :x, :y, :z

  def self.[](x, y, z)
    self.new(x, y, z)
  end

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def +(o)
    Vector.new(@x+o.x, @y+o.y, @z+o.z)
  end

  def -(o)
    Vector.new(@x-o.x, @y-o.y, @z-o.z)
  end

  def *(o)
    case o
    when Vector
      @x*o.x + @y*o.y + @z*o.z
    else
      Vector.new(@x*o, @y*o, @z*o)
    end
  end

  def length
    sqrt(self*self)
  end

  def normalize
    return self * (1 / length)
  end

  def slerp(vec, f)
    cosinus = self * vec
    angle = acos(cosinus)
    l1 = sin(angle / 2)
    r = cos(angle / 2)
    l2 = r * tan(angle * (f - 0.5))
    f = l2 / l1 * 0.5 + 0.5
    return (self * (1 - f) + vec * f).normalize
  end

  def to_s
    "[%7.4f, %7.4f, %7.4f]" % [@x, @y, @z]
  end
end

class Triangle
  def initialize(v1, v2, v3)
    @v1 = v1
    @v2 = v2
    @v3 = v3
  end

  def subdivide(frequency)
    @freq = frequency + 1
    faces = []
    for y in 0..frequency
      for x in 0..y
        faces << Triangle.new(self[x, y], self[x, y+1], self[x+1, y+1])
        faces << Triangle.new(self[x, y], self[x+1, y+1], self[x+1, y]) if x < y
      end
    end
    return faces
  end

  def to_s
    "[%s, %s, %s]" % [@v1, @v2, @v3]
  end

private

  def [](x, y)
    return @v1 if y == 0
    p1 = @v1.slerp(@v2, y.to_f / @freq)
    p2 = @v1.slerp(@v3, y.to_f / @freq)
    return p1.slerp(p2, x.to_f / y)
  end
end

class Dome
  def initialize(datahash = nil)
    @faces = []
    if datahash
      points = datahash[:points]
      datahash[:faces].each do |face|
        vertices = face.split(//).map {|v| points[v]}
        add_face(Triangle.new(*vertices))
      end
    end
  end

  def subdivide(frequency)
    new_dome = Dome.new
    @faces.each do |face|
      face.subdivide(frequency).each do |new_face|
        new_dome.add_face(new_face)
      end
    end
    return new_dome
  end

  def add_face(face)
    @faces << face
  end

  def to_s
    @faces.join("\n")
  end
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
      'a' => Vector[ -TETRA_S, -TETRA_Q, -TETRA_R ],
      'b' => Vector[  TETRA_S, -TETRA_Q, -TETRA_R ],
      'c' => Vector[        0,  TETRA_T, -TETRA_R ],
      'd' => Vector[        0,        0,        1 ]
    },
    :faces => %w| acb abd adc dbc |
  },
  :octahedron => {
    :points => {
      'a' => Vector[  0,  0,  1 ],
      'b' => Vector[  1,  0,  0 ],
      'c' => Vector[  0, -1,  0 ],
      'd' => Vector[ -1,  0,  0 ],
      'e' => Vector[  0,  1,  0 ],
      'f' => Vector[  0,  0, -1 ]
    },
    :faces => %w| cba dca eda bea
      def ebf bcf cdf |
  },
  :icosahedron => {
    :points => {
      'a' => Vector[  1,  GOLDEN_MEAN, 0 ],
      'b' => Vector[  1, -GOLDEN_MEAN, 0 ],
      'c' => Vector[ -1, -GOLDEN_MEAN, 0 ],
      'd' => Vector[ -1,  GOLDEN_MEAN, 0 ],
      'e' => Vector[  GOLDEN_MEAN, 0,  1 ],
      'f' => Vector[ -GOLDEN_MEAN, 0,  1 ],
      'g' => Vector[ -GOLDEN_MEAN, 0, -1 ],
      'h' => Vector[  GOLDEN_MEAN, 0, -1 ],
      'i' => Vector[ 0,  1,  GOLDEN_MEAN ],
      'j' => Vector[ 0,  1, -GOLDEN_MEAN ],
      'k' => Vector[ 0, -1, -GOLDEN_MEAN ],
      'l' => Vector[ 0, -1,  GOLDEN_MEAN ]
    },
    :faces => %w| iea iad idf ifl ile
      eha ajd dgf fcl lbe
      ebh ahj djg fgc lcb
      khb kjh kgj kcg kbc |
  }
}

puts Dome.new(PRIMITIVES[:octahedron]).subdivide(2)
