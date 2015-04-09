require 'singleton'
require 'drb/drb'
require 'galaxy'
require 'sector'
require 'planet'
require 'station'

$SAFE = 1

module Kernel
  alias :lputs :puts
  alias :lgets :gets

  def puts(*args)
    if player = Thread.current[:player]
      player.write(*args)
    else
      lputs(*args)
    end
  end

  def gets
    if player = Thread.current[:player]
      player.read
    else
      lgets
    end
  end
end
    
module SpaceMerchant
  class Controller
    include Singleton

    def initialize
      @players = []
    end

    def register(player)
      Thread.current[:player] = player     
      @players << player      
      lputs "Registered #{player[:name]} (on #{player.__drburi})"
    end

    def quit(player)
      Thread.current[:player] = nil
      @players.delete(player)
      lputs "#{player[:name]} has quit"
    end

    def players
      @players
    end

    def galaxy
      Galaxy.instance
    end
  end

  [Galaxy, Sector, Station, Planet, Controller].each do |clz|
    clz.class_eval { include DRb::DRbUndumped }
  end
end

DRb.start_service('druby://localhost:8787',SpaceMerchant::Controller.instance)
DRb.thread.join

