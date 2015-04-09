# Mutated muppet: The two-faced static bot
strategy =  [4, 2, 5, 6, 1, 7, 11, 8, 12, 3, 13, 9, 10]
shift = rand(4) - 3
13.times do
  $stdout.puts strategy[($stdin.gets[/\d+/].to_i + shift) % 13]
  $stdout.flush
  $stdin.gets
end
