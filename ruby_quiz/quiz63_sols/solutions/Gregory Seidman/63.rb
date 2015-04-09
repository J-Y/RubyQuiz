module Enumerable
  # Lisp-y!
  def cdr
    return self[1..-1]
  end
end

module GridFolding

  Opposite = {
    "L" => "R",
    "R" => "L",
    "T" => "B",
    "B" => "T"
  }

  IsXFold = {
    "L" => true,
    "R" => true,
    "T" => false,
    "B" => false
  }

  def validate_dims(x, y)
    fail "x dimension must be at least 1" if x < 1
    fail "y dimension must be at least 1" if y < 1
    xbits = x.to_s(2).cdr
    ybits = y.to_s(2).cdr
    fail "x dimension must be a power of 2" if xbits.count("1") != 0
    fail "y dimension must be a power of 2" if ybits.count("1") != 0
    return [xbits.length, ybits.length]
  end

  def validate_folds(folds)
    x_folds = folds.count("L") + folds.count("R")
    y_folds = folds.count("T") + folds.count("B")
    if folds.length != (x_folds + y_folds)
      fail "Invalid characters in fold string"
    else
      if x_folds < @x_foldable
        fail "Too few x folds"
      elsif x_folds > @x_foldable
        fail "Too many x folds"
      end
      if y_folds < @y_foldable
        fail "Too few y folds"
      elsif y_folds > @y_foldable
        fail "Too many y folds"
      end
    end
    return folds.split(//)
  end

end

class Grid

  def initialize(x, y)
    @x_foldable, @y_foldable = validate_dims(x, y)
  end

  def fold(fold_str)
    folds = validate_folds(fold_str.upcase)
    zero_corner = ["T", "L"]
    zero_slice = 0
    operations = []
    width = @x_foldable
    height = @y_foldable
    folds.each { |f|
      if not zero_dir(zero_corner)
        zero_slice += operations.length + 1
      end
      if zero_corner[0] == f
        zero_corner[0] = Opposite[f]
      elsif zero_corner[1] == f
        zero_corner[1] = Opposite[f]
      end
      temp_ops = operations.clone()
      op = 0
      if IsXFold[f]
        op = (1 << width) - 1
        width -= 1
      else
        op = ((1 << height) - 1) << @x_foldable
        height -= 1
      end
      operations << op
      operations << temp_ops
      operations.flatten!
    }
    below_zero = operations[0...zero_slice].reverse
    above_zero = operations[zero_slice..-1]
    curval = 0
    below_zero.map! { |n| (curval ^= n) + 1 }
    curval = 0
    above_zero.map! { |n| (curval ^= n) + 1 }
    list = []
    if zero_dir(zero_corner)
      list << above_zero.reverse
      list << 1
      list << below_zero
    else
      list << below_zero.reverse
      list << 1
      list << above_zero
    end
    return list.flatten!
  end

  private
  include GridFolding

  #true is up
  def zero_dir(zero_corner)  
    not ((zero_corner[0]=="T") ^ (zero_corner[1]=="L"))
  end
end

# vim:ts=2 sw=2 ai expandtab foldmethod=syntax foldcolumn=5
