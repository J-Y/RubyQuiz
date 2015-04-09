# Here is my solution.
# It solves the minimum requirements with minimal error checking.
# Removes some parentheses.
#str = "1 56 35 + 16 9 - / +"
str = "1 2 - 3 4 - - 2 * 7.4 + 3.14 * 2 / 1.2 + 3 4 - -"
ops = %w[+ - * /]
arr = str.split(/\s+/)
err = arr.select {|c| c =~ /^\d+\.?\d?/ || ops.include?(c)}
the_stack = []

if arr.length == err.length
  arr.each_with_index do |x,y|
  the_stack << x unless ops.include?(x)
    if ops.include?(x) && the_stack.length > 1
    b = the_stack.pop
    a = the_stack.pop
    the_stack << "(#{a} #{x} #{b})" if (x == "+" || x == "-") && (y < (arr.length - 1))
    the_stack << "#{a} #{x} #{b}" if x == "*" || x == "/" || y == (arr.length - 1)
    end
  end
  puts the_stack[0]
end
