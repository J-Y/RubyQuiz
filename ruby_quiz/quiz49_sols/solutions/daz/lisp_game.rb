#
# Dave Butcher 2005/10/02 - Ruby Quiz #49
#     ( daz-49@d10.karoo.co.uk )
#
require 'singleton'

SEP = '-'*50

class World
  include Singleton
  def initialize

    @@locs = {}  # {:loc => Location object}

    set_location(:living_room, ['whisky-bottle', 'bucket'],
        [
          ['west', 'door', :garden],
          ['upstairs', 'stairway', :attic],
        ], <<-xxx)
      > You are in the living-room of a Wizard's house.
      > There is a Wizard snoring loudly on the couch.
    xxx
    set_location(:attic, nil,
        [
          ['downstairs', 'stairway', :living_room],
        ], <<-xxx)
      > You are in the attic of the abandoned house.
      > There is a giant welding torch in the corner.
    xxx
    set_location(:garden, ['chain', 'frog'],
        [
          ['east', 'door', :living_room],
        ], <<-xxx)
      > You are in a beautiful garden.
      > There is a well in front of you.
    xxx

    @@actions = []  # ['splash', 'weld', 'dip']

    game_action('splash', ['_wizard', 'bucket'], :living_room) do
      if !@bucket_filled
        puts '## The bucket has nothing in it. ##'
      elsif have('frog')
        msg(<<-xxx)
          > The wizard awakens and sees that you stole his frog.
          > He is so upset he banishes you to the netherworlds -
          > You lose!  THE END?
        xxx
        throw(:done)
      else
        msg(<<-xxx)
          > The wizard awakens from his slumber and greets you warmly.
          >        He hands you the magic low-carb donut
          >        ***------------------------------***
          >        ***  Congratulations - you WIN!  ***
          >        ***------------------------------***
          >                   T H E   E N D
        xxx
        throw(:done)
      end
    end

    game_action('weld', ['chain', '_bucket'], :attic, false) do
      if have('bucket')
        @chain_welded = true
        msg(<<-xxx)
          > The chain is now securely welded to the bucket.
        xxx
      else
        puts '##  You do not have a bucket.  ##'
      end
    end

    game_action(['dunk', 'dip', 'lower'], ['bucket', '_well'], :garden) do
      if @chain_welded
        @bucket_filled = true
        msg(<<-xxx)
          > The bucket is now full of water.
        xxx
      else
        puts '##  The water level is too low to reach.  ##'
      end
    end

    @chain_welded  = false
    @bucket_filled = false

    @carrying = []                     #  Items picked up

    @location = @@locs[:living_room]   #  Where you are now.
    #=======#
       run                             #  GO!
    #=======#
  end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def World.create(*start_cmds)
    @@start_cmds = start_cmds[0] ||''
    World.instance  #  Singleton - "World.new"
  end

  def run
    catch(:done) do
      @@start_cmds.each { |cmd| dispatch(cmd) }
      STDOUT.sync=true
      look
      loop {
        print '~> '
        dispatch(STDIN.gets)
      }
    end # :done
  end

  def dispatch(cmd)
    cmd.downcase!
    cmd.strip!
    verb = cmd[/\A\w+/] or return
    rest = $'.strip
    throw(:done) if verb =~ /exit|quit/
    puts "\n%s\n~> %s %s" % [SEP, verb.upcase, rest.upcase]
    send(verb, rest)
  end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #****************#
  # Basic commands #
  #****************#

  def look(null=nil)
    puts @location.desc
    @location.describe_each_path
    @location.describe_floor
  end

  def walk(dir)
    nloc = @location.plan.detect { |m| dir == m[0] }
    if nloc
      @location = @@locs[ nloc[2] ]
      puts SEP
      look
    else
      puts '##  You cannot go that way.  ##'
    end
  end
  alias :go  :walk

  def pickup(item)
    if pick = @location.items.delete(item)
      @carrying << pick
      puts "You are now carrying the #{pick}."
    else
      puts '##  You cannot get that.  ##'
    end
  end
  alias :pick :pickup
  alias :get  :pickup

  def drop(item)
    if pick = @carrying.delete(item)
      @location.items << pick
      puts "You have put down the #{pick}."
    else
      puts '##  You are not carrying that.  ##'
    end
  end

  def inventory(null=nil)
    puts 'Carrying: ' << @carrying.join(', ')
  end

  def have(item)
    @carrying.include?(item)
  end

  #****************#
  # Other commands #
  #****************#

  def method_missing(meth_id, args)
    verb = meth_id.to_s
    if @@actions.include?(verb)
      items = args.split
      ## See if the action is valid here ...
      if action_block = mm_get_blk(verb, items)
        action_block.call
      else
        puts "##  You can't #{verb} like that.  ##"
      end
    else
      puts "I'm not sure how to #{meth_id}"
    end
  end

  def mm_get_blk(verb, items)
    ret_blk = false
    if la = @location.actions.detect { |a| a[0] == verb }
      lverb, litems, lorder, lblock = la
      litems = litems.map { |li| li.dup }
      nochk  = litems.map { |li| li.sub!(/\A_/, '') }
      if  ( lorder ?
              litems == items :
            ( litems  - items ).empty? ) and
          ( nochk[0] or have(items[0]) ) and
          ( nochk[1] or have(items[1]) )
        ret_blk = lblock
      end
    end
    ret_blk
  end

  def msg(msg)
    print msg.gsub(/^\s*> /, '')
  end

  #########
  # Setup #  World
  #########

  def set_location(name, items, plan, desc)
    @@locs[name] = Location.new( name, items, plan,
                     desc.gsub(/^\s*> /, ''), self )
  end

  def game_action(action, items, locname, order=true, &block)
    loc = @@locs[locname]
    [action].flatten.each do |verb|
      @@actions << verb
      loc.add_action(verb, items, order, block)
    end
    # method_missing checks that you have possession
    # of item1 & 2 unless prefixed with an underscore.
  end
end


class Location
  attr_reader :name, :items, :plan, :desc, :actions
  def initialize(name, items, plan, desc, world)
    @world = world  # parent
    @name  = name
    @items = [items].flatten.compact
    @plan  = plan
    @desc  = desc
    @actions = []
  end

  def describe_each_path
    @plan.each { |p| describe_path(p) }
  end

  def describe_path(p)
    puts 'There is a %2$s leading %1$s.' % p
  end

  def describe_floor
    @items.each do |item|
      puts "You see a #{item} on the floor."
    end
  end

  def inspect
    [:Location, @name, @items].inspect
  end

  #########
  # Setup #  Location
  #########

  def add_plan(dir, feat, alt_loc)
    @plan << [ dir, feat, alt_loc ]
  end

  def add_action(verb, items, order, block)
    @actions << [verb, items, order, block]
  end
end

test_cmds = <<EoC
 look
 rhubarb
# splash
 splash well
 walk west
 walk east
 pickup whisky-bottle
 pickup whisky-bottle
 drop   whisky-bottle
 drop   whisky-bottle
 pick bucket
 inventory
 splash wizard bucket
 walk west
 pick chain
 go east
 go upstairs
 weld bucket chain
 weld chain bucket
 go downstairs
 go west
 dip bucket well
 get frog
 go east
 splash wizard bucket
# look
EoC

#cheat_sheet = [cheat_cmds].pack('m')
cheat_sheet = <<EoC
IGxvb2sKIHBpY2sgYnVja2V0CiB3YWxrIHdlc3QKIHBpY2sgY2hhaW4KIGdv
IGVhc3QKIGdvIHVwc3RhaXJzCiB3ZWxkIGNoYWluIGJ1Y2tldAogZ28gZG93
bnN0YWlycwogZ28gd2VzdAogZGlwIGJ1Y2tldCB3ZWxsCiBnbyBlYXN0CiBz
cGxhc2ggd2l6YXJkIGJ1Y2tldAo=
EoC

#ARGV.replace(['-test']) if ARGV.empty?
#ARGV.replace(['-cheat']) if ARGV.empty?

cmds = cheat_sheet.unpack('m')[0] if ARGV.include?('-cheat')
cmds = test_cmds << "\nQUIT\n"    if ARGV.include?('-test')

World.create(cmds)  # nil/false takes STDIN
