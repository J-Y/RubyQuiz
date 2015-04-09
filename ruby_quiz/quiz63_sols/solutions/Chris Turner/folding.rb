# A few helper methods

def try
  begin
    yield
  rescue
  end
end

class Object
  def deep_dup
    Marshal::load(Marshal.dump(self))
  end
end

module Math
  def Math.log2(num)
    Math.log(num) / Math.log(2)
  end
end

class Fixnum
  def power_of_2?
    power_of_two = 2
    begin
      return true if power_of_two == self
    end while((power_of_two = power_of_two*2) <= self)
    false
  end
end

# First part of solution (plus first extra credit)
class Paper
  attr_reader :paper
  def initialize(size=16)
    raise "Paper size must be power of 2" unless size.power_of_2?
    @paper = []
    (1..size).each do |h|
      @paper.push((((h-1)*size)+1..(((h-1)*size)+size)).to_a)
      @paper[-1].map! {|x| [x]}
    end
    @size = size
    self
  end

  def fold(commands)
    size = commands.size
    folds_req = Math.log2(@size).to_i*2
    raise "Need #{folds_req-size} more folds" if folds_req > size
    raise "Have too many folds (by #{size-folds_req})" if folds_req < size

    directions = parse_fold_commands(commands)
    directions.each do |direction|
      send(direction)
    end
    @paper[0][0]
  end

  def fold_bottom
    fold_vert(false)
  end

  def fold_top
    fold_vert(true)
  end

  def fold_left
    fold_horiz(true)
  end

  def fold_right
    fold_horiz(false)
  end

private
  def parse_fold_commands(commands)
    commands.split("").map do |d|
      case d.downcase
      when "r"
        :fold_right
      when "l"
        :fold_left
      when "t"
        :fold_top
      when "b"
        :fold_bottom
      else
        raise "Invalid command: #{d}"
      end
    end
  end

  def fold_two_halves(new_half, old_half)
    new_half.each_with_index do |new_row, r_index|
      old_row = old_half[r_index]
      new_row.each_with_index do |new_col, c_index|
        old_col = old_row[c_index]
        new_col.unshift(old_col.reverse).flatten!
      end
    end
  end

  def fold_vert(top_to_bottom)
    check_foldable(:v)
    top_half, bottom_half = get_top_and_bottom
    new_half, old_half = if top_to_bottom
                           [bottom_half, top_half]
                         else
                           [top_half, bottom_half]
                         end
    old_half = old_half.reverse
    fold_two_halves(new_half, old_half)
    (@paper.size/2).times do
      if top_to_bottom
        @paper.shift
      else
        @paper.pop
      end
    end
    self
  end

  def fold_horiz(left_to_right)
    check_foldable(:h)
    left_half, right_half = get_left_and_right
    new_half, old_half = if left_to_right
                           [right_half, left_half]
                         else
                           [left_half, right_half]
                         end
    old_half = old_half.map { |x| x.reverse }
    fold_two_halves(new_half, old_half)
    @paper.each do |row|
      (row.size/2).times do
        if left_to_right
          row.shift
        else
          row.pop
        end
      end
    end
    self
  end

  def get_top_and_bottom
    new_size = @paper.size/2
    [@paper[0,new_size], @paper[new_size,new_size]]
  end

  def get_left_and_right
    new_size = @paper[0].size/2
    [@paper.map {|x| x[0,new_size]}, @paper.map {|x| x[new_size,new_size]}]
  end

  def check_foldable(direction)
    if (@paper.size % 2 != 0) || (@paper[0].size % 2 != 0)
      raise "Must be foldable" if @paper.size != 1 && @paper[0].size != 1
    end

    if direction == :v
      raise "Can't fold this direction" if @paper.size == 1
    elsif direction == :h
      raise "Can't fold this direction" if @paper[0].size == 1
    end
  end
end

def fold(command, size=16)
  Paper.new(size).fold(command)
end

if __FILE__ == $0
  paper_size = ARGV[0] || 16
  p fold(STDIN.gets.chomp, paper_size.to_i)
end

#
# Begin extra extra credit-----------------------------------------------------------------------------------
#
class Paper
  def unfold(commands)
    directions = parse_unfold_commands(commands)
    directions.each do |direction|
      send(direction)
    end
    self
  end

  def reset_to(new_paper)
    @paper = new_paper
    self
  end

  def at_start?
    if @paper.size == @size and @paper[0].size == @size
      catch(:not_correct) do
        (0..@size-1).each do |row|
          (0..@size-1).each do |col|
            throw :not_correct if(@paper[row][col][0] != (row*@size)+col+1)
          end
        end
        return true
      end
      false
    end
  end

  def unfold_to_bottom
    check_unfoldable(:v)
    @paper.reverse.each do |row|
      new_row = []
      row.each do |col|
        new_col = []
        (col.size/2).times { new_col.unshift(col.shift) }
        new_row.push(new_col)
      end
      @paper.push(new_row)
    end
    self
  end

  def unfold_to_top
    check_unfoldable(:v)
    me = @paper.dup
    me.each do |row|
      new_row = []
      row.each do |col|
        new_col = []
        (col.size/2).times { new_col.unshift(col.shift) }
        new_row.push(new_col)
      end
      @paper.unshift(new_row)
    end
    self
  end

  def unfold_to_left
    check_unfoldable(:h)
    @paper.each do |row|
      row_dup = row.dup
      row_dup.each do |col|
        new_col = []
        (col.size/2).times { new_col.unshift(col.shift) }
        row.unshift(new_col)
      end
    end
    self
  end

  def unfold_to_right
    check_unfoldable(:h)
    @paper.each do |row|
      row.reverse.each do |col|
        new_col = []
        (col.size/2).times { new_col.unshift(col.shift) }
        row.push(new_col)
      end
    end
    self
  end

private
  def parse_unfold_commands(commands)
    commands.split("").map do |d|
      case d.downcase
      when "r"
        :unfold_to_right
      when "l"
        :unfold_to_left
      when "t"
        :unfold_to_top
      when "b"
        :unfold_to_bottom
      else
        raise "Invalid command: #{d}"
      end
    end
  end

  def check_unfoldable(direction)
    if (@paper.size % 2 != 0) || (@paper[0].size % 2 != 0)
      raise "Must be foldable" if @paper.size != 1 && @paper[0].size != 1
    end

    raise "Already unfolded" if (@paper[0][0].size == 1)
  end
end

def check_fold(ary)
  raise "Invalid solution" unless ary.size.power_of_2?
  answer_size = Math.sqrt(ary.size).to_i
  paper = Paper.new(answer_size).reset_to([[ary.deep_dup]])
  try_all(paper, [""])
end

def try_all(start, directions)
  n = []
  directions.each do |sol|
    new_sol = start.deep_dup.unfold(sol)
    ufl = ufr = uft = ufb = nil

    try { ufl = new_sol.deep_dup.unfold_to_left }
    try { ufr = new_sol.deep_dup.unfold_to_right }
    try { uft = new_sol.deep_dup.unfold_to_top }
    try { ufb = new_sol.deep_dup.unfold_to_bottom }

    return (sol + "l").reverse if ufl and ufl.at_start?
    return (sol + "r").reverse if ufr and ufr.at_start?
    return (sol + "t").reverse if uft and uft.at_start?
    return (sol + "b").reverse if ufb and ufb.at_start?

    n << (sol + "l") if ufl
    n << (sol + "r") if ufr
    n << (sol + "t") if uft
    n << (sol + "b") if ufb
  end
  try_all(start, n) if directions.size != 0
end
