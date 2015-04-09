#!/usr/local/bin/ruby -w

# space_merchant.rb

require "singleton"

module SpaceMerchant
  VERSION = "1.0"

  # We will use a basic Hash, but feel free to add methods to it.
  class Player
    instance_methods.each { |meth| undef_method(meth) unless meth =~ /^__/ }

    include Singleton
    def initialize
      @game_data = Hash.new
    end

    def method_missing( meth, *args, &block )
      @game_data.send(meth, *args, &block)
    end
  end
end

if __FILE__ == $0
  require "galaxy"   # Task 1
  require "sector"   # Task 2
  require "station"  # Task 3
  require "planet"   # Task 4

  # collect beginning player information
  player = SpaceMerchant::Player.instance

  puts
  puts "Welcome to Space Merchant #{SpaceMerchant::VERSION}, " + 
       "the Ruby Quiz game!"
  puts
  
  print "What would you like to be called, pilot?  "
  loop do
    name = gets.chomp
    
    if name =~ /\S/
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
  
  player[:credits]  = 1000
  # we initialize player[:location], it should be changed to move the player
  player[:location] = SpaceMerchant::Galaxy.instance.starting_location

  catch(:quit) do  # use throw(:quit) to exit the game
    # primary event loop
    loop { player[:location].handle_event(player) }
  end
end
