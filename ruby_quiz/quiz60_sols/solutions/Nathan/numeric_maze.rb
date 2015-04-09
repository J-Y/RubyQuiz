$ops = [:double, :halve, :add_two]

def solve(start, finish)
  solve_recur($ops, [[]], start, finish)
end

def solve_recur(ops, op_arrays, start, finish)
  op_arrays.each do |op_array|
    if (is_solution?(op_array, start, finish))
      return print_solution(op_array, start)
    end
  end
  new_op_arrays = multiply_ops(ops, op_arrays)
  solve_recur(ops, new_op_arrays, start, finish)
end

def multiply_ops(ops, op_arrays)
  result = []
  ops.each do |op|
    op_arrays.each do |op_array|
      result << (op_array.clone << op)
    end
  end
  result
end

def is_solution?(op_array, start, finish)
  current = start
  op_array.each do |op|
    return false if op == :halve && current.is_odd?
    current = current.send(op)
  end
  current == finish
end

def print_solution(op_array, start)
  solution = op_array.inject([start]) do |acc, op|
    acc << acc.last.send(op)
  end
  puts solution.inspect
end

class Integer

  def double
    self * 2
  end

  def halve
    raise "unable to halve #{self}" if self.is_odd?
    self / 2
  end

  def add_two
    self + 2
  end

  def is_odd?
    self % 2 != 0
  end

end
