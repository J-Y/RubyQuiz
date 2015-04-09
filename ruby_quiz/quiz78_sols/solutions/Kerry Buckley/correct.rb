Brackets = {'(' => ')', '[' => ']', '{' => '}'}

# Adds missing close brackets (aborts on error unless @fail).
def fix_closings(str)
  closers = []
  fixed = ""
  str.split(//).each do |c|
    if Brackets.has_key?(c)
      # Add expected corresponding bracket to a stack
      closers.push(Brackets[c])
    elsif Brackets.has_value?(c)
      closer = closers.pop
      if closer
        # Append any missing closing brackets
        while closer != c
          abort unless @fix
          fixed << closer
          closer = closers.pop
        end
      else
        abort unless @fix
      end
    end
    fixed << c
  end
  # If we've hit the end of the description, make sure any leftover
  # closing brackets are added
  closers.reverse.each {|a| fixed << a}
  fixed
end

# Reverses the description, mirroring brackets (eg "{foo]" => "[oof}").
def reverse_desc(str)
  new_str = ""
  str.split(//).each do |c|
    if Brackets.has_key?(c)
      new_str << Brackets[c]
    elsif Brackets.has_value?(c)
      new_str << Brackets.invert[c]
    else
      new_str << c
    end
  end
  new_str.reverse
end

@fix = ARGV.shift == "-f"
desc = gets.chomp
# Add missing closing brackets, flip the description and repeat, then flip
# it back the right way round again
fixed = reverse_desc(fix_closings(reverse_desc(fix_closings(desc))))
puts fixed
