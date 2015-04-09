rows = ARGV[0].to_i
triangle = []
if rows >= 1
 triangle.push([1])
end
if rows >= 2
  triangle.push([1, 1])
end
last_row = [1, 1]

count = 3
while count <= rows
  next_row = [1]
  index = 0
  while index < last_row.length - 1
    next_row.push last_row[index]+last_row[index + 1]
    index = index + 1
  end
  next_row.push(1)
  triangle.push(next_row)
  last_row = next_row
  count = count + 1
end

number_length = last_row[last_row.length / 2].to_s.length
triangle_length = last_row.length * number_length + last_row.length - 1
triangle.each do |row|
  final_row = []
  row.each do | number|
    final_row.push(number.to_s.center(number_length))
  end
  puts final_row.join(' ').center(triangle_length)
end