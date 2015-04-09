require 'galaxy'
require 'sector'
require 'planet'
require 'station'

class GalaxyLoader
  class InvalidContext < Exception; end

  def initialize
    @context_stack = []
    @sectors = []
    @neighbors = {}
  end

  def execute(definition)
    instance_eval(definition)
  end

  private
  def galaxy(&block)
    raise InvalidContext, "galaxy allowed only in root context" unless context == nil
    with(:galaxy => Galaxy.instance) do
      instance_eval(&block) if block
      resolve_neighbors
    end
  end

  def region(name, &block)
    raise InvalidContext, "region allowed only in galaxy context" unless context == :galaxy
    with(:region => name) do
      instance_eval(&block) if block
    end
  end

  def sector(name, &block)
    raise InvalidContext, "sector allowed only in galaxy or region context" unless context == :galaxy or context == :region
    with(:sector => Sector.new(name, @region)) do
      instance_eval(&block) if block
      @sectors[name] = @sector
      @galaxy.add_sector(@sector)
    end
  end

  def planet(name, &block)
    raise InvalidContext, "planet allowed only in sector context" unless context == :sector
    with(:planet => Planet.new(@sector, name)) do
      instance_eval(&block) if block
      @sector.add_planet(@planet)
    end
  end

  def station(name, &block)
    raise InvalidContext, "station allowed only in sector context" unless context == :sector
    with(:station => Station.new(@sector, name)) do
      instance_eval(&block) if block
      @sector.add_station(@station)
    end
  end

  def neighbors(*sectors)
    raise InvalidContext, "neighbors allowed only in sector context" unless context == :sector
    @neighbors[@sector] = sectors
  end

  def with(context)
    name = context.keys.first
    value = context[name]
    instance_eval("@#{name} = value")
    @context_stack << name
    yield
    @context_stack.pop
    instance_eval("@#{name} = nil")
  end

  def context
    @context_stack.last
  end

  def resolve_neighbors
    @neighbors.each do |sector,neighbors|
      neighbors.each do |name|
        neighbor = @sectors[name]
        sector.link(neighbor)
      end
    end
  end
end

def Galaxy.load(filename)
  GalaxyLoader.new.execute(File.read(filename))
  Galaxy.instance
end











