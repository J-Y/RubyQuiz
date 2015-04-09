require 'ostruct'

def hashes_to_openstructs( obj )
  return obj unless Hash === obj
  OpenStruct.new( Hash[
    *obj.inject( [] ) { |a, (k, v)| a.push k, hashes_to_openstructs( v ) }
  ] )
end
