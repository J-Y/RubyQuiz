def describe_location( location, map )
  map[location].first
end

def describe_path( path )
  "There is a #{path[1]} going #{path[0]} from here."
end

def describe_paths( location, map )
  map[location][1..-1].map { |p| describe_path(p) }.join("  ")
end

def is_at?( object, location, object_locations )
  location == object_locations[object]
end

def describe_floor( location, object_locations )
  object_locations.select { |obj, loc| loc == location }.map do |obj, loc|
    "You see a #{obj} on the floor."
  end.join("  ")
end

def look
  [ describe_location($location, $map),
    describe_paths($location, $map),
    describe_floor($location, $object_locations) ].join("  ").strip
end


def walk_direction( direction )
  if to = $map[$location][1..-1].assoc(direction)
    $location = to.last
    look
  else
    "You can't go that way."
  end
end

alias walk walk_direction
alias go walk_direction

def pickup_object( object )
  if is_at? object, $location, $object_locations
    $object_locations[object] = "body"
    "You are now carrying #{object}."
  else
    "You cannot get that."
  end
end

alias pickup pickup_object
alias get pickup_object
alias take pickup_object

def inventory
  $objects.select { |obj| $object_locations[obj] == "body" }
end

def have?( object )
  inventory.include? object
end

def game_action( action, subject, object, location, &block )
  $stringify << object unless $stringify.include? object
  self.class.send(:define_method, action) do |sub, obj|
    begin
      if $location == location and 
         subject == sub and object == obj and have?(subject)
         block[sub, obj]
      else
        raise
      end
    rescue
      "You can't #{action} like that."
    end
  end
end
