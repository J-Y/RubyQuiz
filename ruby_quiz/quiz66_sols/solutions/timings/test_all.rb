Dir['*generator.*'].each do |f|
  puts "\n### TESTING: #{f}"
  system "ruby tests.rb #{f}"
end
