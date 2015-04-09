require 'matrix'
require 'rational'

class Matrix
  def update_row(num, new_row)
    arows = self.row_vectors.map{|r| r.to_a}
    new_rows = []
    arows.each_with_index {|r, i| new_rows << (i == num ? new_row : r)}
    Matrix[*new_rows]
  end
  
  def add_row_with_factor(row_i1, row_i2, factor)
    row1 = self.row_vectors[row_i1].to_a
    row2 = self.row_vectors[row_i2].to_a
    new_row = []
    row1.each_with_index do |el1, i|
      new_row << el1 + row2[i]*factor
    end
    self.update_row(row_i1, new_row)
  end
end
  
class HomogenousLinearSolver
end

class << HomogenousLinearSolver 
  # use this, where matrix is a Matrix
  def solve(matrix)
    ref = row_echelon_form(matrix)
    get_solutions(ref)
  end
  
  def leading_zeros(row)
    i = 0
    row.to_a.each do |el|
      if el == 0
        i += 1
      else
        return i
      end
    end
    i
  end

  def first_non_zero(row)
    row.to_a.find{|e| e != Rational(0, 1)}
  end

  def column_of_first_non_zero(row)
    row.to_a.each_with_index {|e, i| return i if e != Rational(0, 1)}
  end

  def column_is_unitary?(cv)
    col = cv.to_a
    col.select{|el| el == Rational(1, 1)}.length == 1 and
      col.select{|el| el == Rational(0, 1)}.length == col.length - 1
  end

  def in_row_echelon_form?(matrix)
    leading_zeros = []
    matrix.row_vectors.each do |row|
      leading_zeros << leading_zeros(row)
      if non_zero(row)
        return false if first_non_zero(row) != Rational(1, 1)
        col = matrix.column(column_of_first_non_zero(row))
        return false unless column_is_unitary?(col)
      end
    end
    unless leading_zeros.sort == leading_zeros
      return false
    end
    true
  end

  def split_matrix(matrix)
    unitary = []
    other = []
    matrix.column_vectors.each_with_index do |cv, i|
      if column_is_unitary?(cv)
        unitary << [cv, i]
      else
        other << [cv, i]
      end
    end
    [unitary, other]
  end

  def lcm(array)
    array.inject {|lcm, el| el.lcm lcm }
  end

  def get_solutions(matrix)
    unitary_cols, other_cols = split_matrix(matrix)
    sols = []
    other_cols.each do |arr|
      solution_vector = arr[0]
      word_index = arr[1]
      lcm = lcm(solution_vector.to_a.collect {|el| el.denominator})
      new_solution_vector = solution_vector.to_a.map {|el| el*lcm}
      values = Array.new(matrix.column_size, Rational(0, 1))
      values[word_index] = Rational(lcm, 1)
      unitary_cols.each_with_index do |arr, i|
        this_word_index = arr[1]
        values[this_word_index] = -new_solution_vector[i]
      end
      sols << values
    end
    sols
  end

  def normalize_row_to_leading_one(matrix, row_i)
    row = matrix.row(row_i).to_a
    leading_el = first_non_zero(row)
    row.map! {|el| el/leading_el}
    matrix.update_row(row_i, row)
  end

  def non_zero(row)
    row.to_a.each {|el| return true if el != Rational(0, 1)}
    false
  end

  def row_echelon_iteration(matrix)
    sorted_rows = matrix.row_vectors.sort_by {|r| leading_zeros(r)}.map{|r| r.to_a}
    matrix = Matrix[*sorted_rows]
    (0..(matrix.row_size-1)).each do |row_i|
      row = matrix.row(row_i)
      if non_zero(row)
        if first_non_zero(row) != Rational(1, 1)
          matrix = normalize_row_to_leading_one(matrix, row_i)
          row = matrix.row(row_i)
        end
        column_i = column_of_first_non_zero(row)
        unless column_is_unitary?(matrix.column(column_i))
          (0..(matrix.row_size-1)).each do |row_i2|
            if row_i2 != row_i and matrix[row_i2, column_i] != Rational(0, 1)
              matrix = matrix.add_row_with_factor(row_i2, row_i, -matrix[row_i2, column_i])
            end
          end
        end
      end
    end
    matrix
  end

  def row_echelon_form(inmatrix)
    matrix = inmatrix.clone
    oldmatrix = nil
    until in_row_echelon_form?(matrix)
      matrix = row_echelon_iteration(matrix)
    end
    matrix
  end
end

if __FILE__ == $0
  require 'test/unit'

  class TestHomogenousLinearSolver < Test::Unit::TestCase
    def setup
      @a = [[3, 1, 0], 
            [3, 0, 2],
            [0, 0, 0]]
      @a.collect! {|r| r.collect! {|e| Rational(e, 1)}}
      @a = Matrix[*@a]
      
      @b = rl(Matrix[[1,  0,  2],
                     [0,  2, -2],
                     [0,  0,  0]])
      
      @c = Matrix[*[[Rational(1, 1), Rational(1, 1), Rational(2, 3)], 
                    [Rational(0, 1),  Rational(1, 1),-Rational(2, 1)],
                    [Rational(0, 1),  Rational(0, 1), Rational(0, 1)]]]
      
      @d = Matrix[*[[Rational(0, 1),  Rational(1, 1),-Rational(2, 1)], 
                    [Rational(1, 1), Rational(0, 1), Rational(2, 3)],
                    [Rational(0, 1),  Rational(0, 1), Rational(0, 1)]]]
      
      @e = Matrix[*[[Rational(0, 1),  Rational(0, 1), Rational(0, 1)],
                    [Rational(1, 1), Rational(0, 1), Rational(2, 3)], 
                    [Rational(0, 1),  Rational(1, 1),-Rational(2, 1)]
                   ]]
      
      @f = Matrix[*[[Rational(1, 1), Rational(0, 1), Rational(2, 3)], 
                    [Rational(0, 1),  Rational(1, 1),-Rational(2, 1)],
                    [Rational(0, 1),  Rational(0, 1), Rational(0, 1)]]]
      
      @g = rl(Matrix[[1, 0, 2],
                     [1, 1, 1],
                     [0, 0, 0]])
      
      @h = rl(Matrix[[1, 1, 2],
                     [0, 1, 1],
                     [0, 0, 0]])
      
      @i = rl(Matrix[
                     [1, 1],
                     [0, 1],
                     [0, 0],
                     [0, 0]
                    ])
    end
    
    def rl(mat)
      nr = mat.row_vectors.map do |rv| 
        rv.to_a.map do |e| 
          if e.is_a? Rational
            e
          else
            Rational(e, 1)
          end
        end
      end
      Matrix[*nr]
    end
    
    def test_lcm
      assert_equal 6, HomogenousLinearSolver.lcm([1, 2, 3])
      assert_equal 12, HomogenousLinearSolver.lcm([4, 3, 6])
      assert_equal HomogenousLinearSolver.lcm([1, 2, 3, 4, 5, 6, 7, 8, 9]),
      HomogenousLinearSolver.lcm([9, 3, 6, 5, 2, 4, 7, 8, 1])
    end
    
    def test_in_row_echelon_form?
      assert !HomogenousLinearSolver.in_row_echelon_form?(@a)
      assert !HomogenousLinearSolver.in_row_echelon_form?(@b)
      assert !HomogenousLinearSolver.in_row_echelon_form?(@c)
      assert !HomogenousLinearSolver.in_row_echelon_form?(@d)
      assert !HomogenousLinearSolver.in_row_echelon_form?(@e)
      assert HomogenousLinearSolver.in_row_echelon_form?(@f)
      assert !HomogenousLinearSolver.in_row_echelon_form?(@g)
      assert !HomogenousLinearSolver.in_row_echelon_form?(@h)
      assert !HomogenousLinearSolver.in_row_echelon_form?(@i)
    end
    
    def test_get_solutions
      mat = [
             [1, 0, Rational(2, 3)],
             [0, 1, -2],
             [0, 0, 0]
            ]
      assert_equal [[-Rational(2, 1), Rational(6, 1), Rational(3, 1)]], 
      HomogenousLinearSolver.get_solutions(rl(Matrix[*mat]))
    end
    
    def test_get_solutions_both
      a = Matrix[[1, 0, Rational(2, 3), Rational(1, 3)],
                 [0, 1, -2,              0]]
      assert_equal [[Rational(-2, 1), Rational(6, 1), Rational(3, 1), Rational(0, 1)],
                    [Rational(-1, 1), Rational(0, 1), Rational(0, 1), Rational(3, 1)]],
      HomogenousLinearSolver.get_solutions(rl(a))
    end
    
    def test_get_solution_when_no_solutions
      matre = rl(Matrix[
                        [1, 0],
                        [0, 1],
                        [0, 0],
                        [0, 0]
                       ])
      assert_equal [], HomogenousLinearSolver.get_solutions(matre)
    end
    
    def test_rl
      a = Matrix[[3, 1, 0], 
                 [3, 0, Rational(1, 3)],
                 [0, 0, 0]]
      b = Matrix[[Rational(3, 1), Rational(1, 1), Rational(0, 3)], 
                 [Rational(3, 1),  Rational(0, 1),Rational(1, 3)],
                 [Rational(0, 1),  Rational(0, 1), Rational(0, 1)]]
      assert_equal b, rl(b)
    end

    def test_normalize_row_to_leading_one
      mat = Matrix[[2, 4, 6]]
      assert_equal Matrix[[1, 2, 3]], HomogenousLinearSolver.normalize_row_to_leading_one(mat, 0)
      mat = Matrix[[1, 2, 3], [2, 4, 6]]
      assert_equal Matrix[[1, 2, 3], [1, 2, 3]], HomogenousLinearSolver.normalize_row_to_leading_one(mat, 1)
      mat = Matrix[[Rational(3, 1), Rational(1, 1), Rational(0, 1)], 
                   [Rational(3, 1), Rational(0, 1), Rational(2, 1)], 
                   [Rational(0, 1), Rational(0, 1), Rational(0, 1)]]
      mat1 = Matrix[[Rational(1, 1), Rational(1, 3), Rational(0, 1)], 
                    [Rational(3, 1), Rational(0, 1), Rational(2, 1)], 
                    [Rational(0, 1), Rational(0, 1), Rational(0, 1)]]
      assert_equal mat1, HomogenousLinearSolver.normalize_row_to_leading_one(mat, 0)
    end
    
    def test_add_row_with_factor
      mat = Matrix[[1, 2, 3], [0, 1, 6]]
      assert_equal Matrix[[1, 0, -9], [0, 1, 6]],
      mat.add_row_with_factor(0, 1, -2)
    end
    
    def test_row_echelon_iteration
      mat = rl(Matrix[[1, 1, 2],
                      [0, 1, 1],
                      [0, 0, 0]])
      after_mat = rl(Matrix[[1, 0, 1],
                            [0, 1, 1],
                            [0, 0, 0]])
      assert_equal after_mat, HomogenousLinearSolver.row_echelon_iteration(mat)
    end
    
    def test_row_echelon_form_3x3
      mat = rl(Matrix[[1, 0, Rational(2, 3)],
                      [0, 1, -2],
                      [0, 0, 0]])
      assert_equal mat, HomogenousLinearSolver.row_echelon_form(@a)
    end

    def test_row_echelon_form_2x2
      matre = rl(Matrix[
                        [1, 0],
                        [0, 1]
                       ])
      mat = rl(Matrix[
                      [0, 1],
                      [2, 0]
                     ])
      assert_equal matre, HomogenousLinearSolver.row_echelon_form(mat)
    end
    
    def test_row_echelon_form_4x2
      mat = rl(Matrix[
                      [3, 3],
                      [0, 1],
                      [1, 1],
                      [0, 0]
                     ])
      matre = rl(Matrix[
                        [1, 0],
                        [0, 1],
                        [0, 0],
                        [0, 0]
                       ])
      assert_equal matre, HomogenousLinearSolver.row_echelon_form(mat)
    end
  end
end