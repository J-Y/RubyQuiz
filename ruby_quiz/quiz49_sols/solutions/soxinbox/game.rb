#the wizard of 3 rooms
$map = [    ["living room","you are in the living-room of a wizard\'s house. 
there is a wizard snoring loudly on the couch.",
            ["bottle of Jack Daniels","bucket"],
            [["west","door","garden"],["upstairs","stairway","attic"]]],
        ["garden","you are in a beautiful garden. there is a well in front 
of you.",
            ["chain","frog"],
            [["east","door","living room"]]],
        ["attic","you are in the attic of the abandoned house. there is a 
giant welding torch in the corner.",
            [],
            [["downstairs","stairway","living room"]]]  ]
$location = "living room"
$knapsack = ["pet rock"]
$Commands = %w{look inventory get walk weld fill dunk }

def look(command)
    myroom = $map.assoc($location)
    print "#{myroom[1]}\n"
    myroom[2].each{|item| print "There is a #{item} on the floor\n"}
    myroom[3].each{|route|
        print "There is a #{route[1]} going #{route[0]} from here\n"
    }
end
def inventory(command)
    if $knapsack.length == 0
        print "you have nothing in your knapsack\n"
    else
        $knapsack.each{|item| print "you have a #{item} in your knapsack\n"}
    end
end
def get(command)
    if command.length < 2
        print "get what?\n"
    else
        command.shift
        object = command.join(" ")
        if $map.assoc($location)[2].include?(object)
         $knapsack << object
         $map.assoc($location)[2].delete(object)
         print "you now have a #{object}\n"
     else
         print "you can't get #{object}\n"
  end
    end
end
def walk(command)
    if command.length <2
        print "pacing..\n"
    elsif (route = $map.assoc($location)[3].assoc(command[1])) == nil
        print "you can't go #{command[1]} from #{$location}\n"
    else
        $location = route[2]
        look(["look"])
    end
end
def go(command)
    walk(command)
end
def weld(command)
    if not command.include?("chain") or not command.include?("bucket")
        print "I don't understand!, Weld what to what?\n"
    elsif $location != "attic"
        print"There is no welder here\n"
    elsif $knapsack.include?("chain") and $knapsack.include?("bucket")
        $knapsack.delete("bucket")
        $knapsack.delete("chain")
        $knapsack << "bucket on a chain"
    else
        print"You need a bucket and a chain to do that\n"
    end
end
def fill(command)
    if $location != "garden"
        print"There is no water here\n"
    elsif not command.include?("bucket")
        print "I don't understand!, What do you want to fill?\n"
    elsif $knapsack.include?("bucket")
        print "The water is to far down to reach with the bucket\n"
    elsif $knapsack.include?("bucket on chain")
        $knapsack.delete("bucket on chain")
        $knapsack << "bucket of water on chain"
        print"You now have a bucket of water on a chain\n"
    elsif $knapsack.include?("bucket of water on chain")
        print"The bucket is already full\n"
    else
        print"You have nothing to fill\n"
    end
end
def dunk(command)
    if not $knapsack.include?("bucket of water on chain")
        print"you have no water\n"
    elsif not command.include?("wizard")
        print "splash\n"
    elsif $location != "living room"
        print "There is no wizard here\n"
    elsif $knapsack.include?("frog")
        print"The wizard is awoken. He sees you have stolen his frog. He 
banishes you to Siberia\n"
        print"You Lose\n"
        abort
    else
        print"The wizard is awoken. He gives you the low carb donut (Yum!) 
and you live happily ever after\n"
        print"You Win\n"
        abort
    end
end

STDOUT.flush
command = ["look"]

while command[0] != "end"
    if $Commands.include?(command[0])
        eval command[0] + "(command)"
    else
        print "Huh?\n"
    end
    print "?"
    STDOUT.flush
    input = gets
    command = input.split(" ")
    puts command
end
