#! /usr/bin/env ruby
#  name_picker.rb
#  Quiz 129
#  
#  Created by Morton Goldberg on June 25, 2007
#  Picks winners for prizes to be given away at the Lone Star Ruby
#  Conference. To create suspense, several seconds are spent teasing
#  the audience before the winner's name is shown.

ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH << File.join(ROOT_DIR, "lib")

require 'tk'
require "picker_model"
require "picker_view"

# Set up the Name Picker window.
root = Tk.root
root.title('LSRC Name Picker')
win_w, win_h = 640, 480
win_lf = (root.winfo_screenwidth - win_w) / 2
root.geometry("#{win_w}x#{win_h}+#{win_lf}+50")
root.resizable(false, false)

# Make Cmnd+Q work as expected on OS X.
if RUBY_PLATFORM =~ /darwin/
   root.bind('Command-q') { root.destroy }
end

# Instantiate the model and the view.
model = PickerModel.new
view = PickerView.new(root, win_w, model)

# Show the window.
Tk.mainloop
