
$objects = [:whiskey_bottle, :bucket, :frog, :chain]

$map = {
	:living_room => ["you are in the living-room of a wizard's house. there is a wizard snoring loudly on the couch.",
		{:west => ["door", :garden], :upstairs => ["stairway", :attic]}],
	:garden => ["you are in a beautiful garden. there is a well in front of you.",
		{:east => ["door", :living_room]}],
	:attic => ["you are in the attic of the abandoned house. there is a giant welding torch in the corner.",
		{:downstairs => ["stairway", :living_room]}]
}

$object_locations = {
	:whiskey_bottle => :living_room,
	:bucket => :living_room,
	:chain => :garden,
	:frog => :garden
}

$location = :living_room

def describe_location(location, map)
	map[location][0]
end

def describe_path(paths, direction)
	"there is a #{paths[direction][0]} going #{direction} from here."
end

def describe_paths(location, map)
	paths = map[location][1]
	paths.keys.map { |dir| describe_path(paths, dir) }.join(" ")
end

def is_at(obj, loc, obj_loc)
	obj_loc[obj] == loc
end

def describe_floor(loc, objs, obj_loc)
	objs.find_all { |obj| is_at(obj, loc, obj_loc) }.map { |obj|
		"you see a #{obj} on the floor."
	}.join(" ")
end

def look
	[
	describe_location($location, $map),
	describe_paths($location, $map),
	describe_floor($location, $objects, $object_locations)
	].join(" ")
end

def walk_direction(direction)
	next_loc = $map[$location][1][direction]
	if next_loc
		$location = next_loc[1]
		look
	else
		"you can't go that way."
	end
end

# map all missing methods without arguments to there name as symbol, so the
# player can write bucket instead of :bucket
def method_missing(m, *a, &b)
	a.empty? ? m : super
end

alias :walk :walk_direction

def pickup_object(object)
	if is_at(object, $location, $object_locations)
		$object_locations[object] = :body
		"you are now carrying the #{object}"
	else
		"you cannot get that."
	end
end

alias :pickup :pickup_object

def inventory
	$objects.find_all { |obj|
		is_at(obj, :body, $object_locations)
	}
end

def have(object)
	inventory.include? object
end

def game_action(command, subj, obj, place, &block)
	self.class.class_eval {
		define_method(command) { |subject, object|
			if $location == place && subject == subj && object == obj && have(subj)
				instance_eval &block
			else
				"i can't #{command} like that."
			end
		}
	}
end

$chain_welded == false
$bucket_filled == false

game_action(:weld, :chain, :bucket, :attic) {
	if have(:bucket) && ($chain_welded = true)
		"the chain is now securely welded to the bucket."
	else
		"you do not have a bucket."
	end
}

game_action(:dunk, :bucket, :well, :garden) {
	if $chain_welded
		$bucket_filled = true
		"the bucket is now full of water."
	else
		"the water level is too low to reach."
	end
}

game_action(:splash, :bucket, :wizard, :living_room) {
	if !$bucket_filled
		"the bucket has nothing in it."
	elsif have(:frog)
		"the wizard awakens and sees that you stole his frog. he is so upset he banishes you to the netherworlds- you lose! the end."
	else
		"the wizard awakens from his slumber and greets you warmly. he hands you the magic low-carb donut- you win! the end."
	end
}
