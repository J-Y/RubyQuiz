require 'enumerator'
require 'tk'

require 'Win32API'
keystate = Win32API.new("user32", "GetKeyState", 'I', 'I')
# virtual keycodes, mapping keys like http://www.pdc.kth.se/%7Elfo/chip8/CHIP8.htm does
VK = {'q' => 81, 0 => 110,  1 => 103, 2 => 104, 3 => 105,  4 => 100, 5 => 101, 6 => 102, 7 => 97, 8 => 98, 9 => 99, 0xA => 96, 0xB => 13, 0xC => 111, 0xD => 106, 0xE => 109, 0xF => 107}

$key_pressed = proc{|key|
  keystate.call(VK[key]) & ~1 != 0  # higher bit set  = key currently pressed
}


class Integer
  def lo;  self & 0xF    end    # low nibble of byte
  def hi; (self >> 4).lo end    # high nibble of byte
  def bcd_byte
    [self / 100, (self/10) % 10, self % 10].map{|n| n.chr}.join
  end
end

class Chip8Emulator
  COLORS = ['#000000','#ffffff']
  FONT_TO_BIN = {' ' => 0,'#' => 1}
  FONT = ["####   #  #### #### #  # #### #### #### #### ####  ##  ###   ### ###  #### #### ",
          "#  #  ##     #    # #  # #    #       # #  # #  # #  # #  # #    #  # #    #    ", 
          "#  #   #  ####  ### #### #### ####   #  #### #### #### ###  #    #  # ###  ###  ",
          "#  #   #  #       #    #    # #  #  #   #  #    # #  # #  # #    #  # #    #    ",
          "####  ### #### ####    # #### ####  #   #### #### #  # ###   ### ###  #### #    "
         ].map{|l| l.split('').enum_slice(5).to_a }.transpose.map{|lines|
             lines.map{|line| (line.map{|c| FONT_TO_BIN[c] }.join + '000').to_i(2).chr }.join
          }.join # FONT is now the encoded font: 5 bytes for 0, 5 bytes for 1, etc   total 80 bytes

  def initialize(code)
    @ip = 0x200
    @mem  = FONT + "\0" * (@ip - 80)  + code + "\0" * 4096  # ensure 4kb mem + program at start
    @regs = "\0" * 160
    @I  = 0
    @stack = []
    init_screen
  end

  def +(a,b)
    a += b
    @regs[0xF] = a > 0xFF ? 1 : 0
    a & 0xFF
  end

  def -(a,b)
    a -= b
    @regs[0xF] = a < 0 ? 0 : 1
    (a + 0x100) & 0xFF
  end
  
  def get_keypress
    sleep 0.01 until k = (0..0xF).find{|k| $key_pressed.call(k) }
    k
  end
  
  def init_screen
    @screen = Array.new(32) {Array.new(64,0) }
    @img_screen = TkPhotoImage.new('width'=>64,'height'=>32)
    @img_screen.put( Array.new(32) {Array.new(64,COLORS[0]) } )
    update_screen
  end
  
  def draw_sprite(x,y,size)
    x %= 64
    y %= 32
    @regs[0xF] = 0
    img_update = Array.new(size){ Array.new(8) }
    @mem[@I,size].split('').each_with_index{|b,dy|
      ypos = (y+dy) % 32
      (0..7).each{|dx|
        chr = b[0][7-dx]
        xpos = (x+dx) % 64
        @regs[0xF] = 1 if(chr==1 && @screen[ypos][xpos]==1)  # collision
        col = @screen[ypos][xpos] ^= chr
        img_update[dy][dx] = COLORS[col]
      }
    }
    @img_screen.put(img_update, :to => [x,y] )
    update_screen
  end
  
  def update_screen
    $tkscreen.copy(@img_screen,:zoom=>10)
  end
  
  def fetch
    @instr = @mem[@ip,2]
    @ip += 2
  end

  def execute
    x   = @instr[0].lo
    y   = @instr[1].hi
    opt = @instr[1].lo
    kk  = @instr[1]
    nnn = @instr[0].lo << 8 | @instr[1]
    case @instr[0].hi
      when 0
        case kk
          when 0xE0 then init_screen                                        #  00E0 Erase the screen
          when 0xEE then @ip = @stack.pop                                   #   00EE Return from a CHIP-8 sub-routine
          else return nil
        end
      when 1   then @ip = nnn                                               # 1NNN Jump to the address NNN of the file
      when 2                                                                #  2NNN Call CHIP-8 sub-routine at NNN
        @stack.push @ip
        @ip = nnn
      when 3   then @ip += 2 if @regs[x] == kk                              # 3XKK Skip next instruction if VX == KK
      when 4   then @ip += 2 if @regs[x] != kk                              # 4XKK Skip next instruction if VX != KK
      when 5   then @ip += 2 if @regs[x] ==  @regs[y]                       # 5XY0 Skip next instruction if VX == VY
      when 6   then @regs[x]  = kk                                          #  6XKK VX = KK
      when 7   then @regs[x]  = self.+(@regs[x],kk)                         # 7XKK VX = VX + KK
      when 8 
        case opt
          when 0   then @regs[x]  = @regs[y]                                 #  8XY0 VX = VY
          when 1   then @regs[x] |= @regs[y]                                 #  8XY1 VX = VX OR VY      
          when 2   then @regs[x] &= @regs[y]                                 #  8XY2 VX = VX AND VY          
          when 3   then @regs[x] ^= @regs[y]                                 #  8XY3 VX = VX XOR VY          
          when 4   then @regs[x]  = self.+(@regs[x],@regs[y])                # 8XY4 VX = VX + VY
          when 5   then @regs[x]  = self.-(@regs[x],@regs[y])                # 8XY5 VX = VX - VY
          when 6   then @regs[0xF], @regs[x] = @regs[x][0], @regs[x] >> 1    # 8X06 VX = VX SHIFT RIGHT 1 VF = least significant bit
          when 7   then @regs[x]  = self.-(@regs[y],@regs[x])                # 8XY7 VX = VY - VX
          when 0xE then @regs[0xF], @regs[x] = @regs[x][7], @regs[x] << 1    # 8X0E VX = VX SHIFT LEFT 1, VF = most significant bit
          else return nil
        end
      when 9   then @ip += 2 if @regs[x] !=  @regs[y]                       # 9XY0 Skip next instruction if VX != VY
      when 0xA then @I   = nnn                                              #  ANNN  I = NNN
      when 0xB then @ip  = nnn + @regs[0]                                   #   BNNN Jump to NNN + V0 
      when 0xC then @regs[x]  = kk & rand(0xFF)                             #   CXKK VX = Random number AND KK
      when 0xD then draw_sprite(@regs[x],@regs[y],opt)                      #   DXYN Draws a sprite at (VX,VY) starting at M(I). VF = collision. If N=0, draws the 16 x 16 sprite, else an 8 x N sprite.
      when 0xE
        case kk
          when 0x9E  then  @ip +=2  if     $key_pressed.call @regs[x]       #  EX9E Skip next instruction if key VX pressed
          when 0xA1  then  @ip +=2  unless $key_pressed.call @regs[x]       #  EXA1 Skip next instruction if key VX not pressed
          else return nil
        end
      when 0xF
        case kk
          when 0x07 then @regs[x] = @delay_timer                            #  FX07 VX = Delay timer
          when 0x0A then @regs[x] = get_keypress                            #  FX0A Waits a keypress and stores it in VX
          when 0x15 then @delay_timer = @regs[x]                            #  FX15 Delay timer = VX
          when 0x18 then                                                    #  FX18 Sound timer = VX, not implemented as it doesn't do anything except beep
          when 0x1E then @I += @regs[x]                                     #  FX1E I = I + VX
          when 0x29 then @I = 5 * @regs[x]                                  #  FX29 I points to the 4 x 5 font sprite of hex char in VX ( font at start of mem, 5 bytes per char)
          when 0x33 then @mem[@I,2] = @regs[x].bcd_byte                     #  FX33 Store BCD representation of VX in M(I)...M(I+2)
          when 0x55 then @mem[@I,x+1] = @regs[0..x]                         #  FX55 Save V0...VX in memory starting at M(I)
          when 0x65 then @regs[0..x]  = @mem[@I,x+1]                        #  FX65 Load V0...VX from memory starting at M(I)
          else return nil
        end
      else return nil
    end
    return true
  end

  def run
    Thread.new {
      @key_timer = @delay_timer = 0
      loop{  
        sleep 1.0 / 60
        @delay_timer -= 1  if  @delay_timer > 0
        @key_timer   -= 1  if  @key_timer > 0
        @key_pressed = nil if  @key_timer == 0
        exit! if $key_pressed.call('q')
      }
    }

    loop {
      fetch
      break unless execute
    }
    puts "Halted at instruction %02X%02X " % [@instr[0],@instr[1]]
  end
  
end


$tkscreen = TkPhotoImage.new('width'=>640,'height'=>320)
TkLabel.new(nil, 'image' => $tkscreen ).pack
Thread.new{ Tk.mainloop }

Chip8Emulator.new( File.open(ARGV[0],'rb').read).run if ARGV[0]