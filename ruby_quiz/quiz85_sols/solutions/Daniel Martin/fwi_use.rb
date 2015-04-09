# The following C program was typed into t.c and then
# compiled with gcc in K&R mode, and gcc in ansi mode.
# The results are below.
#
#  int main(int argc, char *argv)
#  {
#    unsigned short int u_four = 4;
#    short int four = 4;
#    long int l_neg_nine = -9;
#  
#    printf("The division yields %ld\n", l_neg_nine / u_four);
#    printf("The modulus yields %ld\n", l_neg_nine % u_four);
#  
#    printf("The all signed division yields %ld\n", l_neg_nine / four);
#    printf("The all signed modulus yields %ld\n", l_neg_nine % four);
#  }
# 
# esau:~$ gcc-2.95 -traditional -o t t.c && ./t
# The division yields 1073741821
# The modulus yields 3
# The all signed division yields -2
# The all signed modulus yields -1
# esau:~$ gcc-2.95 -ansi -o t t.c && ./t
# The division yields -2
# The modulus yields -1
# The all signed division yields -2
# The all signed modulus yields -1 

require 'fwi'

u_four = FWI.new(16,false).new(4)
four = FWI.new(16,true).new(4)
l_neg_nine = FWI.new(32,true).new(-9)

FWI.new(32).set_coerce_method(:kr)
puts "K&R Math:"
print("The division yields %d\n" %
  [FWI.new(32).c_math(l_neg_nine, :/, u_four)])
print("The modulus yields %d\n" %
  [FWI.new(32).c_math(l_neg_nine, :%, u_four)])
print("The all signed division yields %d\n" %
  [FWI.new(32).c_math(l_neg_nine, :/, four)])
print("The all signed modulus yields %d\n" %
  [FWI.new(32).c_math(l_neg_nine, :%, four)])

FWI.new(32).set_coerce_method(:ansi)
puts "\nansi Math:"
print("The division yields %d\n" % 
  [FWI.new(32).c_math(l_neg_nine, :/, u_four)])
print("The modulus yields %d\n" %
  [FWI.new(32).c_math(l_neg_nine, :%, u_four)])
print("The all signed division yields %d\n" % 
  [FWI.new(32).c_math(l_neg_nine, :/, four)])
print("The all signed modulus yields %d\n" % 
  [FWI.new(32).c_math(l_neg_nine, :%, four)])

FWI.new(32).set_coerce_method(:first)
puts "\nRuby Math:"
print("The division yields %d\n" %
  [l_neg_nine / u_four])
print("The modulus yields %d\n" %
  [l_neg_nine % u_four])

print("The all signed division yields %d\n" %
  [l_neg_nine / four])
print("The all signed modulus yields %d\n" %
  [l_neg_nine % four])

# CRC test
# adapted from the assembly-language routines at
# http://www.wps.com/FidoNet/source/DOS-C-sources/Old%20DOS%20C%20library%20source/crc.asm

def xmodem_crc(a,prev_crc=FWI.new(16,false).new(0))
  crc = prev_crc
  a.each_byte{ |al_val|
    al = FWI.new(8,false).new(al_val)
    8.times {
      al.rcl!(1)
      crc.rcl!(1)
      crc ^= 0x1021 if FWI::FWIBase.carry?
    }
  }
  crc
end

def add_crc(s)
  a = s + "\x00\x00"
  crc = xmodem_crc(a)
  a[-2] = crc.to_i >> 8
  a[-1] = crc.to_i & 0xFF
  a
end

def check_crc(s)
  xmodem_crc(s) == 0
end

puts "\nAdding a crc to a classic string:"
a = add_crc('Hello World!')
p a
puts "Modifying:"
a[1] = ?i
p a
puts "check_crc yields: " + check_crc(a).inspect
a[1] = ?e
p a
puts "check_crc yields: " + check_crc(a).inspect

__END__
