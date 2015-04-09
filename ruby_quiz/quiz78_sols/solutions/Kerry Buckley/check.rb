Brackets = {'(' => ')', '[' => ']', '{' => '}'}
@fix = ARGV.shift == "-f"
desc = gets.chomp
closers = []
desc.split(//).each do |c|
  if Brackets.has_key?(c)
    # Add expected corresponding bracket to a stack
    closers.push(Brackets[c])
  elsif Brackets.has_value?(c)
    closer = closers.pop
    if !closer || closer != c
      abort
    end
  end
end
abort if closers.size > 0
puts desc
