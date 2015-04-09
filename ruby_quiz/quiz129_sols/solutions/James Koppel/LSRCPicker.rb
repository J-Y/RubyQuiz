####Door prize picekr for LSRC. The program creates persistance by modifying its
####own source code.
####Command line usage: Without arguments, it runs the name picker
####With the -a argument, combined with the optional -o and -t arguments,
####it adds an attendee's name, organization, and hometown respectively to the program
require 'tk'
require 'enumerator'

$attendees = []
$organization = {}
$hometown = {}

$previous_winners = [nil]


###Adds code_str to this source file right before Tk::mainloop is invoked
def add_code(code_str)

 File.open($0, "a") do |f|
    f.puts code_str
  end
end

class Array
  def first_satisfies_i
    each_with_index {|el, i| return i if yield el}
    nil
  end

  def map_with_index
    mapped = []
    each_with_index {|el, i| mapped[i] = yield(el,i)}
    mapped
  end
end

def get_arg(name)
  arg_proc = proc {|arg| arg =~ /^-/}
   if (i = ARGV.index name)
    ARGV[(i+1)..((j=ARGV[(i+1)..-1].first_satisfies_i(&arg_proc)) ? i+j : -1)
      ].join(' ')
  end
end

###Code to check and process people being added from the command line
unless ARGV==[]
  name, org, town = ['-a','-o','-t'].map{|n| get_arg n}
  add_code <<-EOC

    $attendees <<
 #{name.inspect}
    $organization[#{name.inspect}] = #{org.inspect}
    $hometown[#{name.inspect}] = #{town.inspect}
  EOC
  exit
end

class TkVariable
  ###Makes updating values as easy as it should be
  def []=(*args)
    v = self.value
    v[*args[0...-1]] = args.last
    self.value = v
  end
end

###Simulates a user typing text into a console
###The only way I could get it to wait for the typing to finish before
###continuing was to have it yield when done
def type(tkvar, text, sleep_t=0.05)
  Thread.new(tkvar, text) do |tkvar, text|
    until text.empty?
      sleep sleep_t
      tkvar.value, text[0,1] = tkvar.value+text[0,1], ""
    end
    yield
  end
end

def char_fly(tkvars,
 char_pos, dest_pos)
  incr =(dest_pos.to_f-char_pos)/(tkvars.length-1)
  c = tkvars.last.value[char_pos, 1]
  return if " "==c
  Thread.new(tkvars, char_pos, incr, c) do |tkvars, char_in, incr, c|
    tkvars.reverse.each_cons(2) do |tkvar_prev, tkvar|
      tkvar_prev[char_in.round, 1] = ' '
      char_in += incr
      tkvar[char_in.round, 1] = c
      sleep 0.1
    end
  end
end

root = TkRoot.new {
  title 'Lone Star Ruby Conf Door Prize Picker'
  background '#000000'}
TkMessage.new(root){
  background '#000000'
  borderwidth 0
  justify 'center'
  font 'courier'
  foreground '#C0C0C0'
  text <<EOD

 .+                  
        +h:                 
       -shh`                
      `shhhs                
`........./hhhhy---:--::::.     
`:shhhhyyyyyssyhhhhhhhys/`      
   `:shhhhyo+oyhhhhhy+.         
      `/syyyhhhhyyy:            
       `ohhhhhyssoy:            

 /yhhhdhhhysyh:           
      .shhyo- `:oyhhh`          
      oho-        -+ys          
     -:`             -.         
EOD
}.grid



content_frame = TkFrame.new(root){
  background '#000000'
  grid{rowspan 60; colspan '100'; sticky "ew"}}

##Holds a pseudo-console
console_frame = TkFrame.new(content_frame) {
  background '#000000'
  width 100
  grid{rowspan 100; colspan '100'; sticky "ew"}}
console_var = TkVariable.new " "*100
console = TkLabel.new(console_frame){
  background '#000000'
  foreground '#C0C0C0'
  justify
 'left'
  font TkFont.new('Courier'){size 40}
  grid{rowspan 100; colspan '100'; sticky "ew"}
  height 7
}.textvariable(console_var)

##Holds the list that scrolls all the attendees names
list_frame = TkFrame.new(content_frame)  {
  background '#000000'
  grid{rowspan 100; colspan '100'; sticky "ew"}}
list = TkListbox.new(list_frame){
  background '#000000'
  foreground '#C0C0C0'
  borderwidth 0
  selectforeground '#000000'
  selectbackground '#C0C0C0'
  highlightthickness 0
  width 75
  font TkFont.new('Courier'){size 40}
  listvariable [' ']*10
  height 10
}

#Displays the word "scanning" when the list of attendees scrolled by
#There is significant flicker involved with this method, as everything is drawn as soon
#as I programmatically make the change.
#I was unable to remove the flicker (perhaps by suspending drawng routines, but
#could not find the class responsible in the docs). I had signicant trouble getting updating
#the value of #the listvariable to work; replacing the listvariable worked but was very slow.
#This approach is the best I came up with.
scanning_display = TkListbox.new(list_frame){
  foreground '#000000'
  background '#000000'
  highlightthickness 0
  borderwidth 0
  width 25
  font TkFont.new('Courier'){size 40}
  listvariable [' ']*10
  height 10}

flying_text_frame = TkFrame.new(content_frame) {
  background '#000000'
  width 100}

flying_textboxes = ([nil]*10).map {
  [(v=TkVariable.new(" "*100)),
    TkEntry.new(flying_text_frame){
      background '#000000'
      foreground '#C0C0C0'
      borderwidth 0

 font TkFont.new('Courier'){size 40}
      width 100
      grid{rowspan 100; colspan '100'; sticky "ew"}
    }.textvariable(v)]}.map{|arr|arr[0]}

TkGrid.grid(list, scanning_display)

##The main procedure of the program
run_picker = proc do
  if $ran
    return
  else
    $ran = true
  end
  $attendees = $attendees.sort_by {|n| n.split.reverse.join(' ')}
  type(console_var,"\n") do
    sleep 2
    console_var.value += "Why do you wake me, mortal?\n>"
    sleep 2; type(console_var, "I seek your wisdom and guidance.\n") do
      sleep 2; console_var.value += "What perplexes you?\n>"; sleep 2
      type(console_var, "Tell me the one most worthy of "+
          "receiving this prize.\n") do
        sleep 2
        console_var.value += "Very well; "
        sleep 0.5
        console_var.value += "the time is right for that decision."
        lvar = TkVariable.new $attendees
        sleep 1
        list.listvariable lvar
        scanning_display.listvariable(TkVariable.new(["scanning"]))
        scanning_display.itemconfigure(0, "background"=> "#C0C0C0")
        $attendees[0..-10].each_with_index do |el, i|
          list.yview(i)
          list.selection_set(i)
          sleep 0.01
        end
        list_frame.ungrid
        sleep 0.2
        console_var.value += "\nI have found your worthy candidate." + 
          " Watch and let the mystery reveal itself."
        sleep 3
        console_frame.ungrid
        chosen = nil
        chosen = $attendees[rand($attendees.length)
          ] while $previous_winners.include? chosen
        scrambled = chosen.split(//).map_with_index{|el, i|
          [rand,el,i]}.sort.map{|arr|arr[1..2]}
        scrambled_str = scrambled.map{|el| el[0]}.join
        flying_textboxes.last.value = " "*(50-scrambled_str.length/2)+
          scrambled_str
        flying_text_frame.grid
        sleep 1
        until flying_textboxes.first.value.include? chosen
          ci=rand(scrambled_str.length)
          char_fly(flying_textboxes,  (50-scrambled_str.length/2)+ci,
                  (50-scrambled_str.length/2)+scrambled[ci][1])
          sleep 0.1
        end
        t = $hometown[chosen]
        o = $organization[chosen]
        flying_textboxes[1][50-t.length/2,t.length] = t if t
        flying_textboxes[2][50-o.length/2,o.length] = o if o
        add_code <<-EOC

          $previous_winners << #{chosen.inspect}
        EOC
      end
    end
  end
end

root.bind('FocusIn',
 &run_picker)
at_exit {Tk.mainloop}
