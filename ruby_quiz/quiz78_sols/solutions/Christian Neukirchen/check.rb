def unwrap(desc)
  [desc.gsub!('BB',  'B'), desc.gsub!('(B)', 'B'),
   desc.gsub!('[B]', 'B'), desc.gsub!('{B}', 'B')].nitems > 0
end

def valid?(desc)
  desc = desc.dup
  true  while unwrap desc
  desc == "B" 
end

packet = ARGV.first.to_s
if valid? packet
  puts packet
  exit 0
else
  exit 1
end
