# Marcel Ward   <wardies ^a-t^ gmaildotcom>
# Sunday, 28 January 2007
# Solution for Ruby Quiz number 111 - Counting Toothpicks
#
class Toothpicks
 def initialize
   # Lookups are value indexed arrays that maps to triplets
   # of elements representing:
   # 1. The shortest toothpick string form of the value
   # 2. The number of toothpicks used
   # 3. The number of operators used, i.e. multiply or add
   @lookup_multiplicable = []
   @lookup_summable = []
   @max_cached_value = 0
 end

 def cache_next()
   target = @max_cached_value + 1
   # Find the best multiplicable tootpick expression by trying to
   # multiply together two existing numbers from the multiplicable
   # cache (we only need to search from 2..sqrt(target))
   best_multiplicable = [one() * target, target, 0]
   tpick_op, price_op = multiply()
   x = 2
   while x**2 <= target
     y,remainder = target.divmod(x)
     if remainder == 0
       tpick_x, price_x, ops_x = @lookup_multiplicable[x]
       tpick_y, price_y, ops_y = @lookup_multiplicable[y]
       price = price_x + price_op + price_y
       if (price < best_multiplicable[1]) ||
           (price == best_multiplicable[1] &&
             ops_x + ops_y + 1 < best_multiplicable[2])
         best_multiplicable = [tpick_x + tpick_op + tpick_y, price,
           ops_x + ops_y + 1]
       end
     end
     x += 1
   end

   best_summable = best_multiplicable.dup
   # Now try summing up two existing, cached values to see if this
   # results in a shorter toothpick sum than the multiplicable one.
   tpick_op, price_op = sum()
   x = 1
   y = target - x
   while x <= y
     tpick_x, price_x, ops_x = @lookup_summable[x]
     tpick_y, price_y, ops_y = @lookup_summable[y]
     price = price_x + price_op + price_y
     if (price < best_summable[1]) ||
         (price == best_summable[1] &&
           ops_x + ops_y + 1 < best_summable[2])
       best_summable =[tpick_y + tpick_op + tpick_x, price,
         ops_x + ops_y + 1]
     end
     x += 1
     y -= 1
   end
   @max_cached_value += 1
   @lookup_multiplicable[target] = best_multiplicable
   @lookup_summable[target] = best_summable
 end

 def one()
   "|"
 end

 def multiply()
   ["x", 2]
 end

 def sum()
   ["+", 2]
 end

 def smallest_summable(value)
   # Cache any missing values
   @max_cached_value.upto(value - 1) {cache_next()}
   @lookup_summable[value].dup
 end
end

def show_toothpicks(start, finish=start)
 tp = Toothpicks.new()
 start.upto(finish) do
   |x|
   toothpick_calc, cost = tp.smallest_summable(x)
   puts "#{x}: #{toothpick_calc}  (#{cost})"
 end
end

case ARGV.size
when 1
 show_toothpicks(ARGV[0].to_i)
when 2
 show_toothpicks(ARGV[0].to_i, ARGV[1].to_i)
else
 puts "Usage: ruby toothpick.rb <value>  -or-  <first> <last>"
end
