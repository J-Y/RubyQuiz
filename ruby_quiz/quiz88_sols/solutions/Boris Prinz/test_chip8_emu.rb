require 'test/unit'
require 'chip8_emu'

class Chip8EmulatorTest < Test::Unit::TestCase
  def setup
    @emu = Chip8Emulator.new
  end

  def test_init
    assert_equal [0] * 16, @emu.register
  end

  def test_set_register
    @emu.exec("\x60\x42" + "\x63\xFF" + "\x6F\x66" + "\0\0")
    assert_equal [66, 0, 0, 255] + [0]*11 + [102], @emu.register
  end

  def test_jump
    @emu.exec("\x10\x04" + "\x00\x00" + "\x60\x42" + "\0\0")
    assert_equal [66] + [0]*15, @emu.register
  end

  def test_skip_next
    @emu.exec("\x60\x42" + "\x30\x42" + "\x60\x43" + "\0\0")
    assert_equal [66] + [0]*15, @emu.register
  end

  def test_add_const
    @emu.exec("\x60\xFF" + "\x70\x01" + "\0\0")
    assert_equal [0]*15 + [1], @emu.register
  end

  def test_copy
    @emu.exec("\x60\x42" + "\x81\x00" + "\0\0")
    assert_equal [66]*2 + [0]*14, @emu.register
  end

  def test_or
    @emu.exec("\x60\x03" + "\x61\x05" + "\x80\x11" + "\0\0")
    assert_equal [7, 5] + [0]*14, @emu.register
  end

  def test_and
    @emu.exec("\x60\x03" + "\x61\x05" + "\x80\x12" + "\0\0")
    assert_equal [1, 5] + [0]*14, @emu.register
  end

  def test_xor
    @emu.exec("\x60\x03" + "\x61\x05" + "\x80\x13" + "\0\0")
    assert_equal [6, 5] + [0]*14, @emu.register
  end

  def test_add
    @emu.exec("\x60\x01" + "\x61\x01" + "\x80\x14" + "\0\0")
    assert_equal [2, 1] + [0]*14, @emu.register
  end

  def test_subtract
    @emu.exec("\x60\x00" + "\x61\x01" + "\x80\x15" + "\0\0")
    assert_equal [255, 1] + [0]*13 + [1], @emu.register
  end

  def test_subtract2
    @emu.exec("\x60\x01" + "\x61\x02" + "\x80\x17" + "\0\0")
    assert_equal [1, 2] + [0]*14, @emu.register
  end

  def test_shift_right
    @emu.exec("\x60\xFF" + "\x80\x06" + "\0\0")
    assert_equal [0x7F] + [0]*14 + [1], @emu.register
  end

  def test_shift_left
    @emu.exec("\x60\xFF" + "\x80\x0E" + "\0\0")
    assert_equal [0xFE] + [0]*14 + [1], @emu.register
  end

  def test_rand
    srand 0
    first_rand = rand(256)
    srand 0
    @emu.exec("\xC0\x0F" + "\0\0")
    assert_equal [first_rand & 0x0F] + [0]*15, @emu.register
  end
end
