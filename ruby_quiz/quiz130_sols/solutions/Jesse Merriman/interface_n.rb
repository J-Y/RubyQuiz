require 'interface_core'
require 'ncurses'

module Hangman
  module Interface
    # An Ncurses-based interface. Originally I called this Ncurses instead of N,
    # but then to refer to the originaly Ncurses class you'd need to do
    # Object::Ncurses.
    class N < Core
      def initialize
        setup_screen
        self
      end

      def phrase_pattern
        @screen.mvaddstr 4, 2, 'Phrase:'
        @screen.move *PhraseCoords
        read_line
      end

      def suggest letter
        @screen.mvaddstr 6, 2, 'Computer guess:'
        @screen.mvaddstr 6, 18, letter
        @screen.mvaddstr 7, 2, 'Positions?      '
        read_line.chomp.split(' ').map { |x| x.to_i - 1}
      end

      def display phrase, lives, max_lives
        clear_fields
        body_i = body_index lives, max_lives
        draw Bodies[body_i], *BodyCoords

        #@screen.mvaddstr *PhraseCoords, phrase # Damn, this doesn't work?
        @screen.mvaddstr PhraseCoords.first, PhraseCoords.last, phrase
        @screen.mvaddstr LivesCoords.first, LivesCoords.last, lives.to_s

        @screen.refresh
      end

      def finish user_won
        @screen.move 10, 30
        if user_won
          @screen.addstr 'I lost!'
        else
          @screen.addstr 'I won!'
        end

        read_line
        Ncurses.endwin
      end

      private

      def setup_screen
        Ncurses.initscr
        Ncurses.cbreak
        Ncurses.noecho
        @screen = Ncurses.stdscr
        Ncurses.keypad @screen, true

        @screen.border(*([0]*8))
        @screen.mvaddstr 1, 1, ' Hangman |'
        @screen.mvaddstr 2, 1, '---------+'

        draw Platform, *PlatformCoords

        @screen.refresh
      end

      def clear_fields
        @screen.mvaddstr 7, 18, ' ' * 20
        @screen.mvaddstr LivesCoords.first, LivesCoords.last, ' ' * 6
      end

      # Modified from the ncurses-ruby read_line.rb example. Still fugly.
      def read_line
        line = ''
        pos = 0
        x, y = [], []
        Ncurses.getyx @screen, y, x
        x, y = x.first, y.first
        max_len = @screen.getmaxx - x - 1

        loop do
          @screen.mvaddstr y, x, line
          @screen.move y, x + pos
          char = @screen.getch
          case char
            when Ncurses::KEY_LEFT
              pos = [0, pos - 1].max
            when Ncurses::KEY_RIGHT
              pos = [line.length, pos + 1].min
            when Ncurses::KEY_ENTER, ?\n, ?\r
              return line
            when Ncurses::KEY_BACKSPACE, ?\177
               line = line[0...([0, pos - 1].max)] + line[pos..-1]
               pos = [0, pos - 1].max
               @screen.mvaddstr(y, x + line.length, '   ')
            when ' '[0]..255 # remaining printables
              if (pos < max_len)
                line[pos, 0] = char.chr
                pos += 1
              else
                Ncurses.beep
              end
            else
              Ncurses.beep
          end
        end
      end

      def body_index lives, max_lives
        Bodies.size + (lives * (1 - Bodies.size) / max_lives).round - 1
      end

      def draw item, y, x
        d = lambda { |line| @screen.mvaddstr(y, x, line); y += 1 }
        item.each_line { |line| d[line.chomp] }
      end

      PhraseCoords = [4, 19]
      LivesCoords = [11, 2]

      PlatformCoords = [10, 2]
      Platform = <<EOF
                 .
        +--------+-
        |        |
                 |
                 |
                 |
                 |
                 |
                 |
                 |
                 |
                 |
====================
EOF

      BodyCoords = [13, 8]
      Bodies = ['', <<EOF1, <<EOF2, <<EOF3, <<EOF4, <<EOF5, <<EOF6]
  _
 | |
  +
EOF1
  _
 | |
  +
  |
  |
EOF2
  _
 | |
  +
 -|
/ |
EOF3
  _
 | |
  +
 -|-
/ | \\
EOF4
  _
 | |
  +
 -|-
/ | \\
  ^
 /
/
EOF5
  _
 | |
  +
 -|-
/ | \\
  ^
 / \\
/   \\
EOF6
    end
  end
end
