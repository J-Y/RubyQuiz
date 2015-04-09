# Fold 1-dimensionally "forward" - i.e. Left to Right or Top to bottom
class ForwardFolder
	def fold1d(position, length, depth, thickness)
		if position >= (to_length = length / 2)
		  position -= to_length 
		  depth += thickness
		else
		  position = to_length - position - 1
		  depth = thickness - depth - 1
		end
		[position, to_length, depth, 2*thickness]
	end
end

# Fold 1-dimensionally "backward" - i.e. bottom to top or right to left
class BackwardFolder
	def fold1d(position, length, depth, thickness)
		if position >= (to_length = length / 2)
		  position = length - position - 1
		  depth = thickness - depth - 1
		else
		  depth += thickness
		end
		[position, to_length, depth, 2*thickness]
	end
end

# Mixin to make a Forward or Backward folder a Left or Right folder (respectively)
module LeftRightFolder
  def fold(x, y, w, h, depth, thickness)
  	x, w, depth, thickness = fold1d(x, w, depth, thickness)
  	[x, y, w, h, depth, thickness]
  end
end
    
# Mixin to make a Forward or Backward folder a Top or Bottom fold (respectively)
module TopBottomFolder
  def fold(x, y, w, h, depth, thickness)
  	y, h, depth, thickness = fold1d(y, h, depth, thickness)
  	[x, y, w, h, depth, thickness]
  end
end

# The main class
class Fold
	# Map command letters to a suitable folder object
  FOLDERS = {
		'L' => ForwardFolder.new.extend(LeftRightFolder),
		'R' => BackwardFolder.new.extend(LeftRightFolder),
		'T' => ForwardFolder.new.extend(TopBottomFolder),
		'B' => BackwardFolder.new.extend(TopBottomFolder)
  }
	
	def self.fold(instructions)
    raise("bad instructions") unless instructions.match(/^[LRTB]*$/)

	  folds = instructions.split(//).collect {|i| FOLDERS[i]}
	  
	  # work out the width and height by "unfolding" by the number of Left/Right and Top/Bottom folds respectively
	  orig_width  = 1 << folds.grep(LeftRightFolder).length
	  orig_height = 1 << folds.grep(TopBottomFolder).length
	
	  # and check that they are the same (i.e. that the grid is square (because the spec says so - not that it would break anything)
	  raise("non-square: unequal width (#{orig_width}) and height (#{orig_height}) implied by folds \"#{instructions}\"") unless orig_height == orig_width
	  
	  # Do it - a cell at a time...
	  result = []
	  (0...orig_height).each do |row|
	    (0...orig_width).each do |col|
	    
	      n = row * orig_width + col + 1  # n being the original cell number
	      x, y = col, row
	      w, h = orig_width, orig_height
	      depth = 0
	      thickness = 1
	      
	      # ...and apply the list of folds
			  folds.each do |folder|
	        x, y, w, h, depth, thickness = folder.fold(x, y, w, h, depth, thickness)
	      end
	      
	      result[depth] = n               # record the layer (or depth) that cell n ends up in
	    end
	  end
	  
	  result
	end
end

if __FILE__ == $0
  require 'test/unit'

	class FoldTest < Test::Unit::TestCase
	   def test_2x2
	      folds = {"TR" => [4, 2, 1, 3],
	               "BR" => [2, 4, 3, 1],
	               "TL" => [3, 1, 2, 4],
	               "BL" => [1, 3, 4, 2],
	               "RT" => [1, 2, 4, 3],
	               "RB" => [3, 4, 2, 1],
	               "LT" => [2, 1, 3, 4],
	               "LB" => [4, 3, 1, 2]}
	
	      folds.each do |cmds,xpct|
	         assert_equal xpct, Fold.fold(cmds)
	      end
	   end
	
	   def test_16x16
	      xpct = [189,  77,  68, 180, 196,  52,  61, 205,
	              204,  60,  53, 197, 181,  69,  76, 188,
	              185,  73 , 72, 184, 200,  56,  57, 201,
	              208,  64,  49, 193, 177,  65,  80, 192,
	              191,  79,  66, 178, 194,  50,  63, 207,
	              202,  58,  55, 199, 183,  71,  74, 186,
	              187,  75,  70, 182, 198,  54,  59, 203,
	              206,  62,  51, 195, 179,  67,  78, 190,
	              142, 126, 115, 131, 243,   3,  14, 254,
	              251,  11,   6, 246, 134, 118, 123, 139,
	              138, 122, 119, 135, 247,   7,  10, 250,
	              255,  15,   2, 242, 130, 114, 127, 143,
	              144, 128, 113, 129, 241,   1,  16, 256,
	              249,   9,   8, 248, 136, 120, 121, 137,
	              140, 124, 117, 133, 245,   5,  12, 252,
	              253,  13,   4, 244, 132, 116, 125, 141,
	              157, 109, 100, 148, 228,  20,  29, 237,
	              236,  28,  21, 229, 149, 101, 108, 156,
	              153, 105, 104, 152, 232,  24,  25, 233,
	              240,  32,  17, 225, 145,  97, 112, 160,
	              159, 111,  98, 146, 226,  18,  31, 239,
	              234,  26,  23, 231, 151, 103, 106, 154,
	              155, 107, 102, 150, 230,  22,  27, 235,
	              238,  30,  19, 227, 147,  99, 110, 158,
	              174,  94,  83, 163, 211,  35,  46, 222,
	              219,  43,  38, 214, 166,  86,  91, 171,
	              170,  90,  87, 167, 215,  39,  42, 218,
	              223,  47,  34, 210, 162,  82,  95, 175,
	              176,  96,  81, 161, 209,  33,  48, 224,
	              217,  41,  40, 216, 168,  88,  89, 169,
	              172,  92,  85, 165, 213,  37,  44, 220,
	              221,  45,  36, 212, 164,  84,  93, 173]
	      assert_equal xpct, Fold.fold("TLBLRRTB")
	   end
	
	   def test_invalid
	      assert_raise(RuntimeError) { Fold.fold("LR") }  # too many horz folds
	      assert_raise(RuntimeError) { Fold.fold("TRB") } # too many folds
	      assert_raise(RuntimeError) { Fold.fold("LR") }  # bad input dimensions
	   end
  end
end
