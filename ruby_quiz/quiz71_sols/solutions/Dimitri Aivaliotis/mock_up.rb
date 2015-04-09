  registry = Needle::Registry.new do |reg|

    reg.register( :galaxy ) { Galaxy.new( 'firefly.yaml' ) }
    reg.intercept( :galaxy ).with! { logging_interceptor }
    reg.register( :sector, :model => :multiton ) do |c,p,name,location|
      Sector.new( name, location )
    end
    reg.intercept( :sector ).with! { logging_interceptor }
    reg.register( :planet, :model => :multiton ) do |c,p,name,sector|
      Planet.new( name, sector )
    end
    reg.intercept( :planet ).with! { logging_interceptor }
    reg.register( :station, :model => :multiton ) do |c,p,name,sector|
      Station.new( name, sector )
    end
    reg.intercept( :station ).with! { logging_interceptor }
    reg.register( :player, :model => :multiton ) do |c,p,name|
      Player.new( name )
    end
    reg.intercept( :player ).with! { logging_interceptor }
  end

  galaxy = registry.galaxy

firefly.yaml (partial):
