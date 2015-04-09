def hashes_to_openstructs( obj, memo={} )
  return obj unless Hash === obj
  os = memo[obj] = OpenStruct.new
  obj.each do |k, v|
    os.send( "#{k}=", memo[v] || hashes_to_openstructs( v, memo ) )
  end
  os
end
