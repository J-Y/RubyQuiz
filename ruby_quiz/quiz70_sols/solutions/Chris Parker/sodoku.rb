require 'CSP'

class Sodoku

  def initialize(dimension)
    sqrt = Math.sqrt(dimension)
    if sqrt.ceil == sqrt.floor
      @dimension = dimension
      @known_values = []
    else
      print "dimension for sodoku is an invalid number, must be the square of an integer.\n"
    end
  end
  
  def set_known_value(value, position)#position is [x,y], from upper left hand corner
    if value <= @dimension && position.class == Array && position.length == 2 && position[0] <= @dimension && position[1] <= @dimension
      @known_values<<[position, value]
    else
      print "there is a problem with the value or the position not being a valid number.\n"
    end
  end
  
  def solve
    csp = CSP.new
    dim_s = @dimension.to_s if @dimension >= 10
    dim_s = "0" + @dimension.to_s if @dimension <= 9
    ("01" .. dim_s).each do |x|
      ("01" .. dim_s).each do |y|
        csp.add_var(x+y,(1 .. @dimension))
      end
    end
    ("01" .. dim_s).each do |x|#make constraints for each column
      c = CSPConstraint.new((x+"01" .. x+dim_s).to_a)
      c.set_all_diff_constraint
      csp.add_constraint(c)
    end
    ("01" .. dim_s).each do |y|#make constraints for each row
      c = CSPConstraint.new
      ("01" .. dim_s).each do |x|
        c.add_var(x+y)
      end
      c.set_all_diff_constraint
      csp.add_constraint(c)
    end
    step_val = Math.sqrt(@dimension)
    (1 .. @dimension).step(step_val) do |x_start_box|#make constraints for each box
      (1 .. @dimension).step(step_val) do |y_start_box|
        c = CSPConstraint.new
        (x_start_box ... (x_start_box + step_val)).each do |x|
          (y_start_box ... (y_start_box + step_val)).each do |y|
            if x < 10
              x_s = "0" + x.to_s 
            else
              x_s = x.to_s
            end
            if y < 10
              y_s = "0" + y.to_s
            else
              y_s = y.to_s
            end
            c.add_var(x_s+y_s)
          end
        end
        c.set_all_diff_constraint
        csp.add_constraint(c)
      end
    end
    
    @known_values.each do |pos_and_val|
      x = pos_and_val[0][0]
      y = pos_and_val[0][1]
      if x < 10
        x = "0" + x.to_s 
      else
        x = x.to_s
      end
      if y < 10
        y = "0" + y.to_s
      else
        y = y.to_s
      end
      c = CSPConstraint.new
      c.add_var(x+y)
      c.set_all_eq_constraint(pos_and_val[1])
      csp.add_constraint(c)
    end
    
    return csp.run
  end
  
end

