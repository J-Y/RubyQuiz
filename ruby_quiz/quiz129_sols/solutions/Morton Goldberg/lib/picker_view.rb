#  picker_view.rb
#  Quiz 129
#  
#  Created by Morton Goldberg on 2007-06-24.
#  Modified July 01, 2007
#  The GUI for the Name Picker application

require 'tk'
require "picker_model"

class PickerView
   T_MIN = 3 # min tease time (sec)
   T_MAX = 6 # max tease time (sec)
   TICKS_PER_SEC = 4 # timer events pec second
   PNL_BGCOLOR = {:background => "DarkRed"} # panel background color
   BTN_BGCOLOR = {:highlightbackground => "DarkRed"}
      # note: button background color must be separately specified
   MARGIN = 20 # thickness of border around widgets
   # Messages shown in the teaser widget
   TEASERS = [
      "Who will win?",
      "No winner yet",
      "Will you be lucky?",
      "Winner!"
   ]
    # Image resources needed by the view
   IMAGE_FILES = [
      "stars_0.gif",
      "stars_1.gif",
      "stars_2.gif",
      "all_stars.gif",
      "dim_stars.gif",
      "LSRC_logo.gif",
   ]

   # Class method
   # Are all needed images available?
   def self.image_check
      paths = IMAGE_FILES.collect do |name|
         File.join(ROOT_DIR, "images", name)
      end
      paths.all? { |f| File.exist?(f) }
   end

   # Instance methods
   attr_accessor :winner, :teaser, :pick_button, :exit_button, :stars
   attr_reader :images, :timer, :moving_stars

   def initialize(parent, width, model)
      view = self # solves a scoping problem
      @model = model # data model
      @teaser_index = 0 # TEASERS index
      # Load images.
      unless PickerView.image_check
         puts "Needed image missing in #{File.join(ROOT_DIR, "images")}"
         abort
      end
      @images = {}
      IMAGE_FILES.each do |name|
         key = File.basename(name, ".*").to_sym
         val = TkPhotoImage.new do
            file(File.join(ROOT_DIR, "images", name))
         end
         @images[key] = val
      end
      @moving_stars = [
         @images[:stars_0],
         @images[:stars_1],
         @images[:stars_2],
      ]
      @ticks = 0 # timer event index
      TkFrame.new(parent, PNL_BGCOLOR) do |f|
         # RSRC Logo widget
         x, y = MARGIN, MARGIN
         w, h = width - 2 * MARGIN, 150
         TkLabel.new(f) {
            image view.images[:LSRC_logo]
            place(:x => x, :y => y, :width => w, :height => h)
         }
         # Winner widget; winner's name and affiliation
         x, y = MARGIN, y + h + MARGIN
         w, h = width - 2 * MARGIN, 80
         view.winner = TkMessage.new(f) {
            text "??\n--"
            font.size(28)
            width w
            justify :center
            place(:x => x, :y => y, :width => w, :height => h)
         }
         # Teaser message widget
         x, y = MARGIN, y + h + MARGIN
         w, h = width - 2 * MARGIN, 50
         view.teaser = TkLabel.new(f) {
            text TEASERS[0]
            font.size(36)
            place(:x => x, :y => y, :width => w, :height => h)
         }
         # Marquee (stars) widget
         x, y = MARGIN, y + h + MARGIN
         w, h = width - 2 * MARGIN, 60
         view.stars = TkLabel.new(f, PNL_BGCOLOR) {
            image view.images[:dim_stars]
            place(:x => x, :y => y, :width => w, :height => h)
         }
         # Button frame (Pick button, Exit button)
         x, y = MARGIN, y + h + MARGIN
         w, h = width - 2 * MARGIN, 20
         TkFrame.new(f, PNL_BGCOLOR) do |bf|
            # Pick button
            view.pick_button = TkButton.new(bf, BTN_BGCOLOR) {
               text "Pick Winner"
               command { view.pick_button_action }
               pack(:side => :left)
            }
            # Exit button
            view.exit_button = TkButton.new(bf, BTN_BGCOLOR) {
               text "Exit"
               command { Tk.root.destroy }
               pack(:side => :right)
            }
            bf.place(:x => x, :y => y, :width => w, :height => h)
         end
         f.pack(:fill => :both, :expand => :true)
      end
   end
   # Actions taken when the Pick-Winner button is clicked on.
   def pick_button_action
      if no_more = @model.no_more?
         # tell audiaence no more prizes
         winner.text(no_more)
         winner.update
      else
         # 1. disable buttons
         # 2. reset winner widget
         # 3. start event timer
         pick_button.state = :disable
         exit_button.state = :disable
         winner.text("??\n--")
         winner.update
         @ticks = 0
         @teaser_index = 0
         tick = 1000 / TICKS_PER_SEC
         ticks = (T_MIN + rand(T_MAX - T_MIN + 1)) * TICKS_PER_SEC
         @timer = TkTimer.start(tick, ticks) { timer_event }
      end
   end
   # Actions taken when a timer event occurs.
   def timer_event
      # advance moving stars on every tick
      stars.image(moving_stars[@ticks % moving_stars.size])
      stars.update
      # update teaser widget once a second
      if (@ticks % TICKS_PER_SEC) == 0
         @teaser_index = (@teaser_index + 1) % (TEASERS.size - 1)
         teaser.text(TEASERS[@teaser_index])
         teaser.update
      end
      unless timer.loop_rest > 1
         # last timer event: show winner and enable buttons
         winner.text(@model.winner)
         winner.update
         teaser.text(TEASERS.last)
         stars.image(images[:all_stars])
         pick_button.state = :normal
         exit_button.state = :normal
      end
      @ticks += 1
   end
end
