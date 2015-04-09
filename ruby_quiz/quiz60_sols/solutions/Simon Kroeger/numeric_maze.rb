from, to = ARGV.shift || 222, ARGV.shift || 9999
t = Time.now

path = {from => :found}
while not path.include? to
  path.keys.each do |n|
    path[n + 2] = :add unless path.include?(n + 2)
    path[n * 2] = :mul unless path.include?(n * 2)
    path[n / 2] = :div unless (n % 2) != 0 || path.include?(n / 2)
  end	
end

result = [to]
loop do
  case path[result.last]
    when :add then result << result.last - 2
    when :mul then result << result.last / 2
    when :div then result << result.last * 2
    else break
  end
end

p result.reverse
puts "Time: #{Time.now - t}s"
