require 'adventure'

#The core map data: The what and where.
$map = { "living_room" => [ 
							#Description of room
							"You are in the living_room of a " + 
                            "wizard's house. There is a wizard " +
							"snoring loudly on the couch.",
							
							#Path
                            %w{west door garden},
							
							#Another Path
                            %w{upstairs stairway attic} 
						  ],
							
         "garden"      => [ "You are in a beautiful garden. " +
		                    "There is a well in front of you.",
							
                            %w{east door living_room} 
						  ],
							
         "attic"       => [ 
		 					"You are in the attic of the wizard's house. " +
		                    "There is a giant welding torch in the corner.",
							
                            %w{downstairs stairway living_room} 
						  ] }
$location = "living_room" #The first room you will start in (must be in map)

$objects = %w{whiskey_bottle bucket frog chain} #Objects (props) for the game

$object_locations = { "whiskey_bottle" => "living_room", # A list of where the
                      "bucket"         => "living_room", # objects will appear
                      "chain"          => "garden",
                      "frog"           => "garden" }

#anything in stringify will automatically be converted into a string.
$stringify = %w{west east upstairs downstairs}.push(*$objects) 

#actions
game_action(*%w{weld chain bucket attic}) do |subject, object|
  have?(object) or raise
  $chain_welded = true
  "The chain is now securely welded to the bucket."
end

game_action(*%w{dunk bucket well garden}) do |subject, object|
  $chain_welded or raise
  $bucket_filled = true
  "The bucket is now full of water."
end

game_action(*%w{splash bucket wizard living_room}) do |subject, object|
  $bucket_filled or raise
  if have? "frog"
    "The wizard awakens and sees that you stole his frog.  " +
    "He is so upset he banishes you to the netherworlds--you lose!  The end."
  else
    "The wizard awakens from his slumber and greets you warmly.  " +
    "He hands you the magic low-carb donut--you win!  The end."
  end
end
