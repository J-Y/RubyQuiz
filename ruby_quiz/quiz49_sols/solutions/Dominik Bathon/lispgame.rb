
class TextAdventureEngine

	Location = Struct.new(:description, :paths)
	Path = Struct.new(:description, :destination)

	def describe_location
		@map[@location].description
	end

	def describe_paths
		paths = @map[@location].paths
		paths.keys.map { |dir|
			"there is a #{paths[dir].description} going #{dir} from here."
		}.join(" ")
	end

	def is_at?(object, location)
		@object_locations[object] == location
	end

	def describe_floor
		@objects.find_all { |obj| is_at?(obj, @location) }.map { |obj|
			"you see a #{obj} on the floor."
		}.join(" ")
	end

	def look
		[describe_location, describe_paths, describe_floor].join("\n")
	end

	alias :l :look

	def walk_direction(direction)
		next_loc = @map[@location].paths[direction]
		if next_loc
			@location = next_loc.destination
			look
		else
			"you can't go that way."
		end
	end

	alias :walk :walk_direction
	alias :go :walk_direction
	alias :w :walk_direction

	def pickup_object(object)
		if is_at?(object, @location)
			@object_locations[object] = :body
			"you are now carrying the #{object}"
		else
			"you cannot get that."
		end
	end

	alias :pickup :pickup_object
	alias :take :pickup_object
	alias :get :pickup_object

	def inventory
		@objects.find_all { |obj|
			is_at?(obj, :body)
		}.map { |o| o.to_s }
	end

	alias :i :inventory

	def have?(object)
		is_at?(object, :body)
	end

	def help
		(methods - Object.instance_methods).reject { |m| m=~/\?$/ }.sort
	end

	alias :h :help

	def self.game_action(command, subj, obj, place, &block)
		define_method(command) { |subject, object|
			if @location == place && subject == subj && object == obj && have?(subj)
				instance_eval &block
			else
				"i can't #{command} like that."
			end
		}
	end

	def self.start_irb_game
		$irb_ta = self.new
		Object.class_eval {
			# send missing methods to $irb_ta or return their name as symbol
			def method_missing(m, *a, &b)
				if $irb_ta.respond_to? m
					$irb_ta.send(m, *a, &b)
				elsif (a.empty? && !b)
					m
				else
					super
				end
			end
		}
		String.class_eval {
			# nicer output
			def inspect
				self
			end
		}
	end

end


class WizardGame < TextAdventureEngine

	def initialize
		@objects = [:whiskey_bottle, :bucket, :frog, :chain]

		@map = {
			:living_room => Location.new(
			"you are in the living-room of a wizard's house. there is a wizard snoring loudly on the couch.",
			{:west => Path.new("door", :garden), :upstairs => Path.new("stairway", :attic)}
			),
			:garden => Location.new(
			"you are in a beautiful garden. there is a well in front of you.",
			{:east => Path.new("door", :living_room)}
			),
			:attic => Location.new(
			"you are in the attic of the abandoned house. there is a giant welding torch in the corner.",
			{:downstairs => Path.new("stairway", :living_room)}
			)
		}

		@object_locations = {
			:whiskey_bottle => :living_room,
			:bucket => :living_room,
			:chain => :garden,
			:frog => :garden
		}

		@location = :living_room
	end

	game_action(:weld, :chain, :bucket, :attic) {
		if have?(:bucket)
			@chain_welded = true
			"the chain is now securely welded to the bucket."
		else
			"you do not have a bucket."
		end
	}

	game_action(:dunk, :bucket, :well, :garden) {
		if @chain_welded
			@bucket_filled = true
			"the bucket is now full of water."
		else
			"the water level is too low to reach."
		end
	}

	game_action(:splash, :bucket, :wizard, :living_room) {
		if not @bucket_filled
			"the bucket has nothing in it."
		elsif have?(:frog)
			"the wizard awakens and sees that you stole his frog. he is so upset he banishes you to the netherworlds- you lose! the end."
		else
			"the wizard awakens from his slumber and greets you warmly. he hands you the magic low-carb donut- you win! the end."
		end
	}

end
