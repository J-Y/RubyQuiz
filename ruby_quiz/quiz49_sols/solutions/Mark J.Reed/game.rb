$objects = [ :whiskeyBottle, :bucket, :chain, :frog ]

$map =
{
    :livingRoom => 
        [ "You are in the living room of a wizard's house." +
          "  There is a wizard snoring loudly on the couch.",
          { :west => [ :door, :garden ] ,
            :upstairs => [ :stairway, :attic ] } 
        ],

    :garden => 
        [ "You are in a beautiful garden.  There is a well in front of you.",
          { :east => [ :door, :livingRoom ] }
        ],
    :attic =>
        [ "You are in the attic of the wizard's house." +
          "  There is a giant welding torch in the corner.",
          { :downstairs => [ :stairway, :livingRoom ] }
        ]
}

$locations = 
{
    :whiskeyBottle => :livingRoom,
    :bucket => :livingRoom,
    :chain => :garden,
    :frog  => :garden
}

$location = :livingRoom

def description(location)
    $map[location][0]
end

def exits(location)
   $map[location][1]
end

def contents(location)
    $objects.find_all do
        |obj| 
        $locations[obj] == location 
    end
end

def look(location=$location)
    puts description(location)
    exits(location).each do       
        |k, v|
       puts "There is a #{v[0]} going #{k} from here"
    end
    contents(location).each do
        |obj|
        puts "You see a #{obj} on the floor."
    end
    return 
end

def go(direction)
    if $map[$location][1].include?(direction) then
        $location = $map[$location][1][direction][1]
        look
    else
        puts "You can't go that way."
    end
end

def get(object)
    if $locations[object] == $location then
        $locations[object] = :body
        puts "You are now carrying the #{object}"
    else
        puts "You cannot get that."
    end
end

def inventory
    contents(:body)
end

def have?(object)
    inventory.include? object
end

$chain_welded = false

def weld(*args)
    args.flatten!
    if args.length == 3 && args[1] == :to then
        args.delete_at(1)
    end
    if $chain_welded || args.length != 2 || $location != :attic ||
        !args.include?(:chain) || !args.include?(:bucket) then
        puts "You can't weld like that."
    else
        $chain_welded = true
        puts "The chain is now securely welded to the bucket."
    end
end

def method_missing(*s) 
    return *s.flatten
end
look
