require 'sdl'
require 'simfrost'

class SimFrost

  class Cell
    attr_accessor :contents

    @@colors = {
      :vapor  => 65535,
      :space => 0,
      :ice  => 31
    }
    def to_sdl
      @@colors[@contents]
    end
  end


  def to_sdl(screen)
    @space.each_with_index do |row, i|
      row.each_with_index { |cell, j| screen.put_pixel(i,j,cell.to_sdl) }
    end
    screen.flip
  end

end

  rows       = ARGV[0] && ARGV[0].to_i || 160
  columns    = ARGV[1] && ARGV[1].to_i || 120
  vapor_rate = ARGV[2] && ARGV[2].to_f || 0.25
  pause      = ARGV[3] && ARGV[3].to_f || 0.025

  SDL.init( SDL::INIT_VIDEO )

  screen = SDL::setVideoMode(rows,columns,16,SDL::SWSURFACE)
  SDL::WM::setCaption $0, $0

  s = SimFrost.new(rows, columns, vapor_rate)
  s.to_sdl(screen)
  while s.contains_vapor?
    sleep(pause)
    s.tick
    s.to_sdl(screen)
  end

  while true
    while event = SDL::Event2.poll
      case event
      when SDL::Event2::KeyDown, SDL::Event2::Quit
        exit
      end
    end

  end
