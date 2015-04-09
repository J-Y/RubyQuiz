class Location
  def self.description(d)
    # Even though we're using a constant method name, we use
    # "define_method" instead of "def" in order to form a closure over
    # the local variable "d".
    define_method(:describe) do
      d
    end
  end

  def self.exit_to(direction,location)
    # @exits is a member of the class object itself, not the instances
    @exits ||= {}
    @exits[direction] = location
    e = @exits
    define_method(:exits) do
      e
    end
  end
end

class A < Location
  exit_to :north, :b
  exit_to :east, :garden
  description "You're at point A.  It's very boring."
end

class B < Location
  exit_to :south, :a
  description "Point B is even more boring than Point A."
end
