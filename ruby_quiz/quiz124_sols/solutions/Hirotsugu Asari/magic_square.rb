#!/usr/bin/env ruby -wKU

# Ruby Quiz #124
# Magic Square -- build an NxN magic square

require 'matrix'

class Matrix
  def magic?
    return false if ! self.square?
    
    size = self.row_size
    
    # compute the sum of each row, each column and the diagonals
    magic_sum = (1..size**2).inject{ |s,i| s += i } / size

    begin
      # checks rows and columns
      self.row_vectors.each { |v|
        if v.to_a.inject { |s,i| s += i } != magic_sum
          raise RuntimeError, "row #{v} doesn't add up to #{magic_sum}"
        end
      }
      self.column_vectors.each { |v|
        if v.to_a.inject { |s,i| s += i } != magic_sum
          raise RuntimeError, "column #{v} doesn't add up to #{magic_sum}"
        end
      }

      # check diagonals
      if (0..size-1).inject(0) {|s,i| s += self[i,i] } != magic_sum
        raise RuntimeError, "the main diagonal doesn't add up to #{magic_sum}"
      end

      # finally.... check the other main diagonal
      if (0..size-1).inject(0) {|s,i| s += self[i, -1-i] } != magic_sum
        raise RuntimeError, "the other diagonal doesn't add up to #{magic_sum}"
      end
      
    rescue
      return false
    end
    
    # it passed all checks
    return true

  end
  
  def to_s_pretty
    if ! self.square?
      return self.to_s
    end
    array      = self.to_a
    max_length = array.flatten.sort.last.to_s.length # the length of the largest number to fit in
    s          = ""
    
    until array.empty? do
      row = array.shift
      s  += "+" + "-" * ((max_length+2)*row.length + row.length-1) + "+\n"
      s  += "| " + row.map{ |i| i.to_s.rjust(max_length) }.join(" | ") + " |\n"
    end
    s += "+" + "-" * ((max_length+2)*row.length + row.length-1) + "+"
    
  end
  
  # See <http://mathworld.wolfram.com/MagicSquare.html>
  def Matrix.new_magic_square(n=3)
    n = n.to_i
    if n == 2
      raise ArgumentError, "2x2 magic square does not exist"
    elsif n < 1
      raise ArgumentError, "Cannot create a magic square of size #{n}"
    end
    
    if n % 2 != 0
      return Matrix.new_odd_magic_square(n)
    elsif n % 4 == 0
      return Matrix.new_doubly_even_magic_square(n)
    else
      return Matrix.new_singly_even_magic_square(n)
    end
  end
  
  private
  def Matrix.new_odd_magic_square(n)
    if ! n.integer? || n%2 != 1
      raise RuntimeError, "Internal error on line #{__LINE__}"
    end    
    # generate the NxN magic square by the Siamese method
    a = []
    0.upto(n-1) { |i|
      a[i]=[]
    }

    m = (n-1)/2
    # put 1 in a[0][m], then 2 goes to a[-1][m+1], 3 to a[-2][m+2], ...
    x=0
    y=m
    1.upto(n**2) { |i|
      if (a[x][y]).nil?
        a[x][y] = i
      else
        # this cell is already filled, so we move to the cell below; we had
        # already moved to the upper right cell, so we must offset that move, too
        x += 2
        y -= 1
        a[x%n][y%n] = i
      end
      x = (x-1)%n # move up
      y = (y+1)%n # then right
    }
    
    Matrix.rows(a)
    
  end
  
  def Matrix.new_doubly_even_magic_square(n)
    if ! n.integer? || n%4 != 0
      raise RuntimeError, "Internal error on line #{__LINE__}"
    end    
    
    # first fill the cells in order
    a=[]
    1.upto(n) do |i|
      first = (i-1)*n+1 # first element
      a << (first..(first+n-1)).to_a
    end
    # then replace the entries
    0.upto(n-1) do |i|
      0.upto(n-1) do |j|
        if (i-j)%4 == 0 || (i+j)%4 == 3
          a[i][j] = n**2+1-a[i][j]
        end
      end
    end
    Matrix.rows(a)
  end
  
  def Matrix.new_singly_even_magic_square(n)
    if ! n.integer? || n%4 != 2
      raise RuntimeError, "Internal error on line #{__LINE__}"
    end    
    
    # first generate the magic square of size n/2
    m = (n-2)/4
    matrix = Matrix.new_odd_magic_square(2*m+1).to_a
    
    lux=[] # identifier for "L,U,X" for each 4x4 squares
    # m+1 rows of L's
    1.upto(m+1) do |i|
      lux << (1..(2*m+1)).to_a.map{"L"}
    end
    # 1 row of U's
    lux << (1..(2*m+1)).to_a.map{"U"}
    # m-1 rows of X's
    1.upto(m-1) do |i|
      lux << (1..(2*m+1)).to_a.map{"X"}
    end
    # swap an L and a U as required by the method
    lux[m][m]="U"
    lux[m+1][m]="L"
    
    # finally, fill up the cells
    a = []
    0.upto(n-1) do |i|
      a[i]=[]
      0.upto(n-1) do |j|
        k = i/2
        l = j/2
        case
        when lux[k][l] == "L"
          # 4 1
          # 2 3
          if i%2 == 0
            if j%2 == 0
              a[i][j]=(matrix[k][l]-1)*4+4
            else
              a[i][j]=(matrix[k][l]-1)*4+1
            end
          else
            if j%2 == 0
              a[i][j]=(matrix[k][l]-1)*4+2
            else
              a[i][j]=(matrix[k][l]-1)*4+3
            end
          end # end of case "L"
        when lux[k][l] == "U"
          # 1 4
          # 2 3
          if i%2 == 0
            if j%2 == 0
              a[i][j]=(matrix[k][l]-1)*4+1
            else
              a[i][j]=(matrix[k][l]-1)*4+4
            end
          else
            if j%2 == 0
              a[i][j]=(matrix[k][l]-1)*4+2
            else
              a[i][j]=(matrix[k][l]-1)*4+3
            end
          end # end of case "U"
        when lux[k][l] == "X"
          # 1 4
          # 3 2
          if i%2 == 0
            if j%2 == 0
              a[i][j]=(matrix[k][l]-1)*4+1
            else
              a[i][j]=(matrix[k][l]-1)*4+4
            end
          else
            if j%2 == 0
              a[i][j]=(matrix[k][l]-1)*4+3
            else
              a[i][j]=(matrix[k][l]-1)*4+2
            end
          end # end of case "X"
        else
          raise RuntimeError, "Internal error on line #{__LINE__}"
        end
      end
    end
    
    return Matrix.rows(a)
  end
  
end