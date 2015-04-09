def hash_to_ostruct(hash)
 return hash unless hash.is_a? Hash
 values = {}
 hash.each { |key, value| values[key] = hash_to_ostruct(value) }
 OpenStruct.new(values)
end
