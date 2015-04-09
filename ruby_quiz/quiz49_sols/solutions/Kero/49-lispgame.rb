### Defining the Data for our Game World

# (setf *objects* '(whiskey-bottle bucket frog chain))
#
# The keys in the object_locations relationship Hash :)

# (setf *map* '((living-room (you are in the living-room of a wizards house. there is a wizard snoring loudly on the couch.)
#                            (west door garden)  
#                            (upstairs stairway attic))
#               (garden (you are in a beautiful garden. there is a well in front of you.)
#                       (east door living-room))
#               (attic (you are in the attic of the wizards house. there is a giant welding torch in the corner.)
#                      (downstairs stairway living-room)))
class Area
  def initialize(descr, *elsewhere)
    @descr = descr
    @elsewhere = elsewhere
  end
end

# With hindsight, I might have used an OpenStruct here
# Note the use of the instance variable here, we can clean a couple of things
# up when we replace lists with Structs.
@map = {
  "living_room"=>Area.new("You are in the living-room of a wizards house. There is a wizard snoring loudly on the couch.",
    %w(west door garden),
    %w(upstairs stairway attic)
  ),
  "garden"=>Area.new("You are in a beautiful garden. There is a well in front of you.",
    %w(east door living_room)
  ),
  "attic"=>Area.new("You are in the attic of the wizards house. There is a giant welding torch in the corner.",
    %w(downstairs stairway living_room)
  ),
}

# (setf *object-locations* '((whiskey-bottle living-room)
#                            (bucket living-room)
#                            (chain garden)
#                            (frog garden)))
#
# We want the Areas, not descriptions of locations.
# Could use an iterator to prevent typing "@map[]" for every object
@object_locations = {
  "whiskey_bottle" => @map["living_room"],
  "bucket" => @map["living_room"],
  "chain" => @map["garden"],
  "frog" => @map["garden"],
}

# (setf *location* 'living-room)
@here = @map["living_room"]


### Looking Around in our Game World

# (defun describe-location (location map)
#   (second (assoc location map)))
class Area
  attr_reader :descr
end

# (defun describe-path (path)
#   `(there is a ,(second path) going ,(first path) from here.))
#
# Interesting how a ,() becomes #{}
class Area
  attr_reader :elsewhere
  def Area::path(ary)
    "there is a #{ary[1]} going #{ary[0]} from here."
  end
end

# (defun describe-paths (location map)
#   (apply #'append (mapcar #'describe-path (cddr (assoc location map)))))
class Area
  def paths
    elsewhere.collect {|path|
      Area::path path
    }
  end
end

# (defun is-at (obj loc obj-loc)
#   (eq (second (assoc obj obj-loc)) loc))
#
# Wonderful, we don't need to do anything :)

# (is-at 'whiskey-bottle 'living-room *object-locations*)
@object_locations["whiskey_bottle"] == @here

# (defun describe-floor (loc objs obj-loc)
#   (apply #'append (mapcar (lambda (x)
#                             `(you see a ,x on the floor.))
#                           (remove-if-not (lambda (x)
#                                            (is-at x loc obj-loc))
#                                          objs))))
#
# If objects were part of an Area, #floor would be *much* simpler, but you'd
# need
#   @avatar.inventory << @here.objects.delete(obj) 
# in pickup (and you'd suddenly need @avatar and @avatar.location). Today is
# not the day to bother, we have a wizard to wake up.
class Area
  def Area::floor(obj)
    "You see a #{obj} on the floor."
  end
  def floor(obj_loc)
    obj_loc.select {|obj, loc|
      loc == self
    }.collect {|obj, loc|
      Area::floor obj
    }
  end
end

# defun look ()
#   (append (describe-location *location* *map*)
#           (describe-paths *location* *map*)
#           (describe-floor *location* *objects* *object-locations*)))
#
class Area
  def look(obj_loc)
    ([descr] + paths + floor(obj_loc)).join(' ')
  end
end


### Walking Around In Our World

# (defun walk-direction (direction)
#   (let ((next (assoc direction (cddr (assoc *location* *map*)))))
#     (cond (next (setf *location* (third next)) (look))
#           (t '(you cant go that way.)))))
def walk_direction direction
  there = @here.elsewhere.any? {|ew|  break ew  if ew[0] == direction }
  if there
    @here = @map[there[2]]
    @here.look(@object_locations)  # passing that one is getting annoying...
  else
    "You can't go there"
  end
end


### Casting SPELs

# (defmacro defspel (&rest rest) `(defmacro ,@rest))
def method_missing(sym)
  sym.to_s
end

# (defspel walk (direction)
#   `(walk-direction ',direction))
alias :walk :walk_direction

# (defun pickup-object (object)
#   (cond ((is-at object *location* *object-locations*) (push (list object 'body) *object-locations*)
#                                                       `(you are now carrying the ,object))
#         (t '(you cannot get that.))))
def pickup_object obj
  if @object_locations[obj] == @here
    @object_locations[obj] = :avatar
    "You are now carrying the #{obj}"
  else
    "You can't get that"
  end
end

# (defspel pickup (object)
#   `(pickup-object ',object))
alias :pickup :pickup_object

# (defun inventory ()
#   (remove-if-not (lambda (x)
#                    (is-at x 'body *object-locations*))
#                  *objects*))
def inventory
  @object_locations.select {|obj, loc|  loc == :avatar }.collect {|obj, loc|  obj }
end

# (defun have (object)
#   (member object (inventory)))
def have obj
  inventory.include? obj
end


### Creating Special Actions in Our Game

# (setf *chain-welded* nil)
@chain_welded = false

# (setf *bucket-filled* nil)
@bucket_filled = false

# (defspel game-action (command subj obj place &rest rest)
#   `(defspel ,command (subject object)
#      `(cond ((and (eq *location* ',',place)
#                   (eq ',subject ',',subj)
#                   (eq ',object ',',obj)
#                   (have ',',subj))
#              ,@',rest)
#             (t '(i cant ,',command like that.)))))
#
# While the macro can replace the "rest" (I don't get the &rest/rest part) in
# Lisp 'before' compile time, Ruby must do this run-time. Keep a list?
# I would really like to know what other ppl do here.
@action = {}
def game_action command, subj, obj, place, &rest
  @action[command] = rest
  eval %Q{def #{command} subj, obj
    if @here == @map["#{place}"] and
        subj == #{subj} and obj == #{obj}
      if not have #{subj}
        "You do not have the #{subj}"
      else
        @action["#{command}"].call
      end
    else
      "You can't #{command} like that"
    end
  end}
end

# (game-action weld chain bucket attic
#              (cond ((and (have 'bucket) (setf *chain-welded* 't))
#                     '(the chain is now securely welded to the bucket.))
#                    (t '(you do not have a bucket.))))
game_action(weld, chain, bucket, attic) {
  if not have bucket
    "You do not have the bucket."
  elsif not @chain_welded
    @chain_welded = true
    "The chain is now securely welded to the bucket."
  else
    "You can't weld like that."
  end
}

# (game-action dunk bucket well garden
#              (cond (*chain-welded* (setf *bucket-filled* 't) '(the bucket is now full of water))
#                    (t '(the water level is too low to reach.))))
game_action(dunk, bucket, well, garden) {
  if @chain_welded
    @bucket_filled = true  
    "The bucket is now full of water"
  else
    "The water level is too low to reach"
  end
}

# (game-action splash bucket wizard living-room
#              (cond ((not *bucket-filled*) '(the bucket has nothing in it.))
#                    ((have 'frog) '(the wizard awakens and sees that you stole his frog. 
#                                    he is so upset he banishes you to the 
#                                    netherworlds- you lose! the end.))
#                    (t '(the wizard awakens from his slumber and greets you warmly. 
#                         he hands you the magic low-carb donut- you win! the end.))))
#
# Introduced @game_over, but it is not necessary per se
game_action(splash, bucket, wizard, living_room) {
  if not @bucket_filled
    "The bucket has nothing in it"
  elsif have frog
    @game_over = true
    "The wizard awakens and sees that you stole his frog. He is so upset he banishes you to the Netherlands -- You lose!"
  else
    @game_over = true
    "The wizard awakens from his slumber and greets you warmly. He hands you the magic low-carb donut -- You win!"
  end
}

# when running in irb, you wouldn't need the ugly puts()s

# (look)
puts @here.look(@object_locations)

# (pickup bucket)
puts pickup bucket

# (walk west)
puts walk west

puts pickup chain
puts pickup frog
walk east
puts walk upstairs

# (weld chain bucket)
puts weld chain, bucket

walk downstairs
walk west
puts dunk bucket, well
walk east
puts splash bucket, wizard
