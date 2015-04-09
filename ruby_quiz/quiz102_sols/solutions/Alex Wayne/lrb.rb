# Get filename
filename = ARGV.first
filename += '.lrb' unless filename =~ /\.\w+$/

# load source
source = File.read(filename)

# Initialize variables for loop
inside_block = false
executable_lines = []

# Process file, line by line
source.each do |line|
 # Look for the start of a code block
 if !inside_block && line =~ (/^\\begin\{(\w+)\}/)
   inside_block = Regexp.last_match[1]
   next
 end
 # Look for the end of a code block, with the same identifier that opened it
 if  inside_block && line =~ /^\\end\{#{inside_block}\}/
   inside_block = false
   next
 end
 if inside_block
   # Inside a code block so simply add the lines to the stack
   executable_lines << line
 else
   # Trim off the '>' and add the line to the stack
   executable_lines << line.gsub(/^>\s/, '') if line =~ /^>\s/
 end
end

# Convert array of lines into a single string executable_lines = executable_lines.join("\n")

# Execute the resulting code
eval(executable_lines)
