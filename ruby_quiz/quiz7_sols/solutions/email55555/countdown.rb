$source = [75,2,8,5,10,10]
$target = 926

$expr = nil
$result = nil
$min_error = nil

def show_solution
  puts("source => " + $source * ", ")
  puts("target => #$target")
  puts("solution => #$expr = #$result")
end

def test(result, expr)
  error = ($target - result).abs
  if (error == 0)
    $expr = expr
    $result = result
    show_solution
    exit # comment out this line if want all solutions
  elsif (error < $min_error)
    $min_error = error
    $expr = expr
    $result = result
  end
end

def eval_op(op, val1, val2, expr1, expr2, source, source_expr)
  result = val1.send(op, val2)
  expr = "(#{expr1} #{op} #{expr2})"
  test(result, expr)
  source << result; source_expr << expr
  find(source, source_expr)
  source.pop; source_expr.pop
end

def find(source, source_expr)
  return if (source.size <= 1)
  (0...source.size).each {|i|
    (0...source.size).each {|j|
      next if (i==j)

      if (i < j)
        b = source.slice!(j); a = source.slice!(i)
        b_expr = source_expr.slice!(j); a_expr = source_expr.slice!(i)
      else
        a = source.slice!(i); b = source.slice!(j)
        a_expr = source_expr.slice!(i); b_expr = source_expr.slice!(j)
      end

      if (b != 0)
      #else skip because a+0==a, a-0==a, a*0==0, a/0 ...

        if (i < j) && (a != 0)
        #else skip because (1) '+' is commutative (2) 0+b==0
          eval_op(:+, a, b, a_expr, b_expr, source, source_expr)
        end

        eval_op(:-, a, b, a_expr, b_expr, source, source_expr)

        if (i < j) && (a != 0) && (a != 1) && (b != 1)
        #else skip because (1) '*' is commutative (2) 0*b==0 (3) n*1==n
          eval_op(:*, a, b, a_expr, b_expr, source, source_expr)
        end

        if (a != 0) && (b != 1) # else skip because (1) 0/b==0 (2) n/1==n
          eval_op(:/, a.to_f, b.to_f, a_expr, b_expr, source, source_expr)
        end        
      end

      if (i < j)
        source[i...i] = a; source[j...j] = b
        source_expr[i...i] = a_expr; source_expr[j...j] = b_expr
      else
        source[j...j] = b; source[i...i] = a
        source_expr[j...j] = b_expr; source_expr[i...i] = a_expr
      end      
    }
  }      
end

$min_error = ($source[0] - $target).abs
$expr = $source[0].to_s
if ($min_error == 0)
  show_solution
  exit
end

(1...$source.size).each { |i| test($source[i], $source[i].to_s) }
find($source.dup, $source.map{|e| e.to_s})
show_solution
