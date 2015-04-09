require 'fox'
require 'fox/colors'
require 'sokoban'

include Fox

class SokobanWindow < FXMainWindow

  def initialize( app )
    super( app, "Sokoban for Ruby Quiz #5", nil, nil, DECOR_ALL, 0, 0, 300, 300 )

    menubar = FXMenubar.new( self )
    filemenu = FXMenuPane.new( self )
    levelmenu = FXMenuPane.new( self )
    FXMenuTitle.new( menubar, "&File", nil, filemenu )
    FXMenuTitle.new( menubar, "&Levels", nil, levelmenu )
    FXMenuCommand.new( filemenu, "&Quit\tCtl-Q", nil, getApp(), FXApp::ID_QUIT )

    @sokoban = Sokoban.new
    @sokoban.load_levels( File.read( 'sokoban_levels.txt' ) )
    @sokoban.select_level( 0 )
    menu = nil
    @sokoban.levels.each_with_index do |level, index|
      if index % 15 == 0
        menu = FXMenuPane.new( self )
        FXMenuCascade.new( levelmenu, "#{index}++", nil, menu )
      end

      icon = FXIcon.new( app, nil, 0, IMAGE_KEEP | IMAGE_OPAQUE, 50, 50 )
      icon.create
      FXDCWindow.new( icon ) do |dc|
        paint_map( 50, 50, dc, level.map )
      end
      item = FXMenuCommand.new( menu, nil, icon )
      item.connect( SEL_COMMAND, method( :on_level_chosen ) )
      item.userData = Struct.new(:level, :index).new( level, index )
    end

    @canvas = FXCanvas.new( self, nil, 0, LAYOUT_FILL_X | LAYOUT_FILL_Y )
    @canvas.connect( SEL_PAINT, method( :on_canvas_repaint ) )
    @canvas.connect( SEL_KEYPRESS, method( :on_canvas_keypress ) )
  end

  def create
    super
    show
  end

  def drawMan(dc, x, y, delta )
    dc.foreground = FXColor::Green
    dc.lineWidth = 2
    dc.drawLine( x*delta + 1, y*delta + 1, x*delta + delta -1, y*delta + delta - 1 )
    dc.drawLine( x*delta + delta - 1, y*delta + 1, x*delta + 1, y*delta + delta - 1 )
  end

  def drawCrate(dc, x, y, delta )
    dc.foreground = FXColor::Blue
    dc.fillRectangle( x*delta + delta/4, y*delta + delta/4, delta/2, delta/2 )
  end

  def drawStorage(dc, x, y, delta )
    dc.foreground = FXColor::Red
    dc.fillCircle( x*delta + delta/2, y*delta + delta/2, delta/2 )
  end

  def paint_map( width, height, dc, map )
    dx = width / map.width
    dy = height / map.height
    delta = ( dx > dy ? dy : dx )

    dc.foreground = FXColor::White
    dc.fillRectangle( 0, 0, width, height )

    y = 0
    map.each_row do |row|
      row.each_with_index do |cell, x|
        case cell
        when Map::Wall
          dc.foreground = FXColor::SandyBrown
          dc.fillRectangle( x*delta, y*delta, delta, delta )
        when Map::Storage
          drawStorage( dc, x, y, delta )
        when Map::Crate
          drawCrate( dc, x, y, delta )
        when Map::Man
          drawMan( dc, x, y, delta )
        when Map::CrateOnStorage
          drawStorage( dc, x, y, delta )
          drawCrate( dc, x, y, delta )
        when Map::ManOnStorage
          drawStorage( dc, x, y, delta )
          drawMan( dc, x, y, delta )
        end
      end
      y += 1
    end
  end

  def on_level_chosen( sender, sel, event )
    @sokoban.select_level( sender.userData.index )
    @canvas.focus
  end

  def on_menu_levels_paint( sender, sel, event )
    dc = FXDCWindow.new( sender )
    paint_map( sender.width, sender.height, dc, sender.userData.level.map )
    dc = nil
    GC.start
  end

  def on_canvas_repaint( sender, sel, event )
    dc = FXDCWindow.new( sender )
    paint_map( sender.width, sender.height, dc,  @sokoban.cur_level.map) if @sokoban.cur_level != nil
    dc.foreground = FXColor::Red
    dc.drawText( 10, 10, 'Level finished!!!' ) if @sokoban.cur_level.level_finished?
    dc = nil
    GC.start
  end

  def on_canvas_keypress( sender, sel, event )
    case event.code
    when KEY_Left then @sokoban.cur_level.move( :left )
    when KEY_Right then @sokoban.cur_level.move( :right )
    when KEY_Up then @sokoban.cur_level.move( :up )
    when KEY_Down then @sokoban.cur_level.move( :down )
    when KEY_Escape then @sokoban.cur_level.reset
    end
    @canvas.update
  end

end

app = FXApp.new( "Sokoban", "Sokoban" )
SokobanWindow.new( app )
app.create
app.run

