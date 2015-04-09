class Chip8
 class Instruction
   attr_reader :op,:nn,:x,:y,:kk
   def parse val
     @op = (val&0xF000)>>12
     @nn = (val&0x0FFF)
     @kk = (val&0x00FF)
     @x  = (val&0x0F00)>>8
     @y  = (val&0x00F0)>>4
   end
 end
 def initialize
   @program = []
   @cp = 0
   @v = Array.new(16){0}
 end
 def load filename
   File.open(filename, "rb"){|f|
     while !f.eof
       @program << f.read(2).unpack('n*')[0]
     end
   }
 end
 def run
   halt = false
   i = Instruction.new
   while !halt
     i.parse(@program[@cp])
     @cp+=1
     case i.op
       when 0 then halt=true
       when 1 then @cp = i.nn/2
       when 3 then @cp+=1 if @v[i.x]==i.kk
       when 6 then @v[i.x] = i.kk
       when 7 then @v[0xF],@v[i.x] = (@v[i.x]+ i.kk).divmod 0x100
       when 8
         case i.nn&0xF
           when 0 then @v[i.x] = @v[i.y]
           when 1 then @v[i.x] |= @v[i.y]
           when 2 then @v[i.x] &= @v[i.y]
           when 3 then @v[i.x] ^= @v[i.y]
           when 4 then @v[0xF],@v[i.x] = (@v[i.x]+@v[i.y]).divmod 0x100
           when 5 then @v[0xF],@v[i.x] = (@v[i.x]-@v[i.y]).divmod 0x100
           when 6 then @v[0xF]=@v[i.x][0]
                       @v[i.x]>>=1
           when 7 then c,@v[i.x] = (@v[i.y]-@v[i.x]).divmod 0x100
                       @v[0xF]=1+c
           when 0xE then @v[0xF]=@v[i.x][7]
                         @v[i.x]<<=1
         end
       when 0xC then @v[i.x] = rand(256)&i.kk
     end
   end
 end
 def dump base = 10
   puts @v.map{|e|e.to_s(base)}.inspect
 end
end

if __FILE__ == $0
 c = Chip8.new
 c.load ARGV[0]||"chip8.test"
 c.run
 c.dump(2)
end
