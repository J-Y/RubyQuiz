require 'complex'

class Polynomial

  @@laguerre_fractions = [0.0, 0.5, 0.25, 0.75, 0.13, 0.38, 0.62, 0.88, 1.0]
  @@laguerre_iterations = 10

  def initialize(coefficients)
    @coefficients = coefficients
    @degree = nil
  end

  def dup
    Polynomial.new(@coefficients.dup)
  end

  def [](i)
    @coefficients[i] || 0
  end

  def []=(i,v)
    @coefficients[i]=v
    @degree = nil
  end

  def degree
    if @degree.nil?
      (@coefficients.size-1).downto(0) do |i|
        unless self[i].nil? or self[i].zero?
          @degree = i
          return @degree
        end
      end
      @degree = -1
    end
    @degree
  end

  def deflate!(z)
    b = 0
    degree.downto(0) { |i| self[i],b = b, z*b + self[i] }
    @degree = nil
  end

  def laguerre(z=Complex.new(0.0,0.0))
    (@@laguerre_iterations * @@laguerre_fractions.size).times do |i|
      b = self[degree]
      err = b.abs
      d = f = 0.0
      (degree-1).downto(0) do |j|
        f = z*f + d
        d = z*d + b
        b = z*b + self[j]
        err = b.abs + z.abs * err
      end
      err *= Float::EPSILON
      return z if b.abs <= err
      g = d/b
      h = g*g - 2.0 * f / b
      sq = Math.sqrt( (degree-1)*(degree*h -g*g) )
      gp = g+sq
      gm = g-sq
      gp = gm if gp.abs < gm.abs
      if [gp.abs,gm.abs].max > 0.0
        dz = degree/gp
      else
        dz = (1+z.abs) * Math::exp( Complex::I * i )    
      end
      return z if z == z-dz
      q,r = i.divmod(@@laguerre_iterations)
      if 0 == r
        z -= @@laguerre_fractions[q]*dz
      else
        z = z-dz
      end
    end
    raise "failed to converge after max iterations"
  end

  def roots
    if @roots.nil?
      @roots = []
      p = self.dup
      degree.times do
        z = p.laguerre
        if z.image.abs <= 2 * Float::EPSILON * z.real.abs
          z = Complex.new(z.real,0)
        end
        @roots << z
        p.deflate!(z)
      end
      @roots.map! { |z| laguerre(z) }
    end
    @roots
  end
end

def irr(a, precision=4)
  p = Polynomial.new(a.reverse)
  p.roots.reject do |r|
    r.image.abs > Float::EPSILON or r.real <= 0
  end.map do |r|
    sprintf("%.#{precision.to_i}f", (r.real - 1)).to_f
  end
end
