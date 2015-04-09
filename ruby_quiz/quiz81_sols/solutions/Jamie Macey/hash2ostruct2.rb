def YAML.load_to_open_struct(yaml)
 hash_to_ostruct(load(yaml))
end

def YAML.hash_to_ostruct(data, memo = {})
 # short-circuit returns so body has less conditionals
 return data unless data.is_a? Hash
 return memo[data.object_id] if memo[data.object_id]

 # log current item in memo hash before recursing
 current = OpenStruct.new
 memo[data.object_id] = current

 # and then recursively populate the current object
 data.each do |key, value|
   current.send(key+'=', hash_to_ostruct(value, memo))
 end
 current
end
