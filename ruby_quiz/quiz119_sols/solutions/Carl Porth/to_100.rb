class Array
  def combinations(n)
    case n
    when 0: []
    when 1: self.map { |e| [e] }
    when size: [self]
    else
      (0..(size - n)).to_a.inject([]) do |mem,i|
        mem += self[(i+1)..size].combinations(n-1).map do |rest|
          [self[i],*rest]
        end
      end
    end
  end
end

equations = 0
separator = "************************"

(1..8).to_a.combinations(3).each do |partitions|
  3.times do |n|
    equation = "123456789"

    partitions.reverse.each_with_index do |partition,index|
      equation = equation.insert(partition, (index == n ? ' + ' : ' -
'))
    end

    result = eval(equation)
    equation << " = #{result}"

    if result == 100
      equation = "#{separator}\n#{equation}\n#{separator}"
    end

    puts equation

    equations += 1
  end
end

puts "#{equations} possible equations tested"
