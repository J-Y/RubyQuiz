module LocationClassMethods
def exit_to(place,direction,opts=nil)
portal = (opts[:through] || opts[:via] if opts.respond_to?:[]) || 'door'
class_variable_set(:@@exits, []) unless class_variables.include?(:@@
exits.to_s)
exits = class_variable_get(:@@exits)
exits << Exit.new(direction,portal)
end

def description(desc)
class_variable_set(:@@description, desc)
end

def exits
class_variable_get(:@@exits)
end

def get_description
class_variable_get(:@@description)
end

end

class Location
def self.inherited(sub)
sub.extend(LocationClassMethods)
end

def initialize
@exits = self.class.exits
@description = self.class.get_description
end

def describe
puts @description
describe_exits
end

def describe_exits
@exits.each { |e| puts e.describe }
end
end

class Attic < Location
exit_to :living_room, :down, :via => 'staircase'

description 'You are in the attic of the wizard\'s house. There is a giant
welding torch in the corner.'
end

class Garden < Location
exit_to :living_room, :west

description 'You are standing in a beautiful garden. There is a well in
front of you.'
end

class LivingRoom < Location
exit_to :attic, :up, :via => 'staircase'
exit_to :garden, :east

description 'You are in the living-room of a wizard\'s house. There is a
wizard snoring loudly on the couch.'
end


a = Attic.new
a.describe
