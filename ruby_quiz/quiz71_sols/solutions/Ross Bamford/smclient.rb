require 'singleton'
require 'drb/drb'
require 'main'

module SpaceMerchant
  class Player
    include DRb::DRbUndumped
    
    def read
      gets
    end

    def write(*args)
      puts(*args)
    end
  end
end

puts
puts "Welcome to Space Merchant #{SpaceMerchant::VERSION}, " + 
     "the Ruby Quiz game!"
puts

print "What would you like to be called, pilot?  "
while true
  name = gets.chomp
  
  if name =~ /\S/
    player = SpaceMerchant::Player.instance
    player[:name] = name
    puts "#{player[:name]} it is."
    puts
    
    puts "May you find fame and fortune here in the Ruby Galaxy..."
    puts
    
    break
  else
    print "Please enter a name:  "
  end
end

SERVER_URI = !ARGV.empty? ? ARGV.join('+') : 'druby://localhost:8787'
DRb.start_service

front = DRbObject.new_with_uri(SERVER_URI)
galaxy = front.galaxy

player[:credits] = 1000
player[:location] = galaxy.starting_location
front.register(DRbObject.new(player))

begin
  catch(:quit) do  # use throw(:quit) to exit the game
    # primary event loop
    loop { player[:location].handle_event(DRbObject.new(player)) } #current_server.uri)) }
  end
ensure
  front.quit(DRbObject.new(player))
end

