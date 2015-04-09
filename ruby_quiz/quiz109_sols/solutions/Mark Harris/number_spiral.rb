class NumberSpiral

  include Enumerable
  
  def initialize(dimension)
    @n = dimension
    @even = dimension % 2
    @maxSize = (@n**2 - 1).to_s.length
  end

  def each

    @line=0
    (0..@n-1).map { yield nextLine }
    @line=0
  end

private

  def nextLine
    result = spiral(@n, @line)
    @line+=1
    result.map{ |x| x.to_s.center(@maxSize) }.join(" ")

  end
  
  def spiral(n, l)
    if (n==1)
      0
    elsif (n % 2 ==0)
      #Even
      if (l == 0)
        # Top row, just return it.
        (n**2 - n)..(n**2-1)
      else
        # Same as the square of size (n-1) at line (l-1) with this square's number in front. 

        ([(n**2 - n - l)] << spiral(n-1,l-1)).flatten
      end
    else
      #Odd
      if (l==(n-1))
        # Bottom row, just return it
        a = Array.new
        (n**2-1).downto(n**2-n) { |x| a << x}

        a
      else
        #Same as the square of size (n-1) at line l with this square's number at the end.
        (spiral(n-1,l).to_a << [(n ** 2 - 2*n + 1 + l)]).flatten
      end
    end

  end
end

spiral = NumberSpiral.new((ARGV[0] || 9).to_i)
spiral.each {|x| puts x }