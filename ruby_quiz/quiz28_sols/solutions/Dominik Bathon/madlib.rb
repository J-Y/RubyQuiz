def ask_for(str)
   puts "Give me #{str}:"
   $stdin.gets.chomp
end

keys={}

puts "", ARGV[0].split(".")[0].gsub("_", " "), IO.read(ARGV[0]).gsub(/\(\(([^)]+)\)\)/) {
   if (t=$1) =~ /\A([^:]+):(.+)\z/
      keys[$1]=ask_for($2)
   else
      keys[t] || ask_for(t)
   end
}
