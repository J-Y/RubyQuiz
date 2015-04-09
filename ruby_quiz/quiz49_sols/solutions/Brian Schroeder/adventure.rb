#!/usr/bin/ruby
#
# This is a one to one translation of the lisp tutorial at
# 
#       http://www.lisperati.com/casting.html
#
# into the ruby programming language.
#
# It does not use much of ruby's beauty, because it tries to be as close to the
# original as possible. It is also tweaking the repl to use it directly as the
# interface.  So you could do some cool things. e.g. enter
#
#     10.times do 
#       dirs = look[1].map { | desc | desc[/going (.*?) from here./, 1].to_sym }
#       puts walk dirs[rand(dirs.length)]
#     end
#
# for some random strolling through the world.
#
# Using a method_missing hack it is possible to enter things like this into irb
#
#     splash bottle frog
#
# which is translated into
#
#     splash([:bottle, :frog])
#
# This code is under the ruby licence.
#
# The code can be found at http://ruby.brian-schroeder.de/quiz/adventure/

module Kernel

#(setf *objects* '(whiskey-bottle bucket frog chain))
  Objects = [:whiskey_bottle, :bucket, :frog, :chain]

#(setf *map* '((living-room (you are in the living-room of a wizards house. there is a wizard snoring loudly on the couch.)
#                           (west door garden)  
#                           (upstairs stairway attic))
#              (garden (you are in a beautiful garden. there is a well in front of you.)
#                      (east door living-room))
#              (attic (you are in the attic of the wizards house. there is a giant welding torch in the corner.)
#                     (downstairs stairway living-room))))
  Map = {
     :living_room => {:description => "You are in the living-room of a wizards house. there is a wizard snoring loudly on the couch.",
                      :connections => {:west => [:door, :garden],  
                                       :upstairs => [:stairway, :attic]}},
     :garden      => {:description => "You are in a beautiful garden. there is a well in front of you.",
                      :connections => {:east => [:door, :living_room]}},
     :attic       => {:description => "You are in the attic of the wizards house. there is a giant welding torch in the corner.",
                      :connections => {:downstairs => [:stairway, :living_room] }}
  }

    
#(setf *object-locations* '((whiskey-bottle living-room)
#                           (bucket living-room)
#                           (chain garden)
#                           (frog garden)))
  ObjectLocations = {
    :whiskey_bottle => :living_room,
    :bucket => :living_room,
    :chain => :garden,
    :frog => :garden
  }
  
#(setf *location* 'living-room)
#(setf *chain-welded* nil)
#(setf *bucket-filled* nil)
  State = {
    :location => :living_room,
    :chain_welded => false,
    :bucket_filled => false
  }
  
#(defun describe-location (location map)
#  (second (assoc location map)))
  def describe_location(location, map)
    Map[location][:description]
  end
  
#(defun describe-path (path)
#  `(there is a ,(second path) going ,(first path) from here.))
#  
#(defun describe-paths (location map)
#  (apply #'append (mapcar #'describe-path (cddr (assoc location map)))))
  def describe_paths(connections)
    connections.to_a.map { | (direction, (passage, next_location)) |
      "There is a #{passage} going #{direction} from here."
    }
  end

#(defun is-at (obj loc obj-loc)
#  (eq (second (assoc obj obj-loc)) loc))
  def is_at(object, location, object_locations)
    object_locations[object] == location
  end

#(defun describe-floor (loc objs obj-loc)
#  (apply #'append (mapcar (lambda (x)
#                            `(you see a ,x on the floor.))
#                          (remove-if-not (lambda (x)
#                                           (is-at x loc obj-loc))
#                                         objs))))
  def describe_floor(location, objects, object_locations)
    objects.select { | object | is_at(object, location, object_locations) }.
            map    { | object | "You see a #{object} on the floor." }
  end
  
#(defun look ()
#  (append (describe-location *location* *map*)
#          (describe-paths *location* *map*)
#          (describe-floor *location* *objects* *object-locations*)))
  def look
    [describe_location(State[:location], Map),
    describe_paths(Map[State[:location]][:connections]),
    describe_floor(State[:location], Objects, ObjectLocations)]
  end

#(defun walk-direction (direction)
#  (let ((next (assoc direction (cddr (assoc *location* *map*)))))
#    (cond (next (setf *location* (third next)) (look))
#         (t '(you cant go that way.)))))  
  def walk(direction)
    next_state = Map[State[:location]][:connections][direction]
    if next_state
      State[:location] = next_state[1]
      look
    else
      "You can't go that way."
    end
  end
  
#(defmacro defspel (&rest rest) `(defmacro ,@rest))
  def method_missing(method_id, *args)
    if args.empty?
      method_id
    else
      [method_id] + args
    end
  end

#(defspel walk (direction)
#  `(walk-direction ',direction))
# We need only the method missing hack from above
  
#(defun pickup-object (object)
#  (cond ((is-at object *location* *object-locations*) (push (list object 'body) *object-locations*)
#                                                      `(you are now carrying the ,object))
#       (t '(you cannot get that.))))
  def pickup(object)
    if is_at(object, State[:location], ObjectLocations)
      ObjectLocations[object] = :body
      "You are now carrying the #{object}"
    else
      "You cannot get that."
    end
  end
  
#(defspel pickup (object)
#  `(pickup-object ',object))
# We need only the method missing hack from above
  
#(defun inventory ()
#  (remove-if-not (lambda (x)
#                  (is-at x 'body *object-locations*))
#                *objects*))
  def inventory
    Objects.select { | object | ObjectLocations[object] == :body }
  end
    
#(defun have (object)
#  (member object (inventory)))
  def have(object)
    inventory.include?(object)
  end
  
  #  extend self

#(defspel game-action (command subj obj place &rest rest)
#  `(defspel ,command (subject object)
#     `(cond ((and (eq *location* ',',place)
#                  (eq ',subject ',',subj)
#                  (eq ',object ',',obj)
#                  (have ',',subj))
#             ,@',rest)
#            (t '(i cant ,',command like that.)))))
  def define_game_action(command, subject, object, place, &action) 
    puts "Defining #{command}"
    p self
    define_method(command) do | *args |
      subject_, object_ = *args.flatten
      if State[:location] == place and
	 subject == subject_ and
	 object ==  object_ and
	 have(subject)
        instance_eval &action
      else
	"I can't #{command} like that."
      end
    end
  end

#(game-action weld chain bucket attic
#             (cond ((and (have 'bucket) (setf *chain-welded* 't))
#                    '(the chain is now securely welded to the bucket.))
#                   (t '(you do not have a bucket.))))
  define_game_action(:weld, :chain, :bucket, :attic) do
    if have :bucket 
      State[:chain_welded] = true
      "The chain is now securely welded to the bucket."
    else
      "You do not have a bucket."
    end
  end

#(game-action dunk bucket well garden
#             (cond (*chain-welded* (setf *bucket-filled* 't) '(the bucket is now full of water))
#                   (t '(the water level is too low to reach.))))
                    
  define_game_action(:dunk, :bucket, :well, :garden) do
    if State[:chain_welded] 
      State[:bucket_filled] = true
      "The bucket is now full of water"
    else
      "The water level is too low to reach."
    end
  end

#(game-action splash bucket wizard living-room
#             (cond ((not *bucket-filled*) '(the bucket has nothing in it.))
#                   ((have 'frog) '(the wizard awakens and sees that you stole his frog. 
#                                   he is so upset he banishes you to the 
#                                   netherworlds- you lose! the end.))
#                   (t '(the wizard awakens from his slumber and greets you warmly. 
#                        he hands you the magic low-carb donut --- you win! the end.))))

  define_game_action(:splash, :bucket, :wizard, :living_room) do
    if not State[:bucket_filled] 
      "The bucket has nothing in it."
    elsif have :frog
      ["The wizard awakens and sees that you stole his frog.",
	"He is so upset he banishes you to the netherworlds -- you lose!",
	"                 === The End ==="]
    else
      ["The wizard awakens from his slumber and greets you warmly.",
	"He hands you the magic low-carb donut --- you win!",
	"                 === The End ==="]
    end
  end

  def help
    puts %(You can do the following things
                          - look
                          - pickup
                          - walk
                          - weld
                          - dunk
                          - splash
    )
  end
end

if __FILE__ == $0
  require 'irb'
  
  IRB.start
end

