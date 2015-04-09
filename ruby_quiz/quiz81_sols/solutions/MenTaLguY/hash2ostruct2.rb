require 'ostruct'
require 'lazy'

def hashes_to_openstructs( obj, memo={} )
  return obj unless Hash === obj
  memo[obj.object_id] ||= promise {
    OpenStruct.new( Hash[
      *obj.inject( [] ) { |a, (k, v)|
        a.push k, hashes_to_openstructs( v, memo )
      }
    ] )
  }
end
