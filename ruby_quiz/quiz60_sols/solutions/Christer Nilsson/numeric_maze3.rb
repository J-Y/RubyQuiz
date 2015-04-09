def solve start, target
  return [start] if start == target
  @max = 2 + 2 * [start,target].max
  @back = []
  @back[start] = start
  @back[target] = -target
  @ready = nil
  q1 = [start]
  q2 = [target]
  loop do
    q1 = solve_level(q1, 1)
    break if @ready
    q2 = solve_level(q2, -1)
    break if @ready
  end
  path(@ready[1]).reverse + path(@ready[0])
end

def path(number)
  nr = abs(@back[number])
  [number] + (nr == number ? [] : path(nr))
end

def solve_level(queue, sign)
  @queue = []
  @sign = sign
  queue.each do |number|
    store number, number * 2
    store number, number + 2 * sign
    store number, number / 2 if number[0] == 0
    break if @ready
  end
  @queue
end

def store number, result
  return if result > @max
  return if result <= 0
  if @back[result].nil? then
    @queue.unshift result
    @back[result] = number * @sign
  else
    if sign(@back[result]) == -@sign then
      @ready = number, result
    end
  end
end

def abs(x) x > 0 ? x : -x end
def sign(x) x > 0 ? 1 : -1 end
