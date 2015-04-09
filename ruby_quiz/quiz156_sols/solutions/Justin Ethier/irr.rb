# Solve polynomial for given value of X and coefficients
def poly(x, coeff)
 (0...coeff.size).inject(0) {|sum, i| sum + coeff[i] * (x ** (coeff.size - i - 1))}
end

# Solve for first derivative of a polynomial for given value of X and coefficients
def poly_first_deriv(x, coeff)
 poly(x, (0...coeff.size-1).inject([]){|deriv, i| deriv << coeff[i] * (coeff.size - i - 1)})
end

def irr(coeff)
 x, last_x = 1.0, 0.0
 10.times do ||
   last_x = x
   x = x - (poly(x, coeff) / poly_first_deriv(x, coeff))
   return (x - 1) * 100 if (last_x - x).abs < 0.00001
 end
 nil
end
