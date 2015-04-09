# My straight-forward solution.

require 'enumerator'

# How much can the time differ?
FUZZ = 0

POS = { ?1 => [0,0], ?2 => [1,0], ?3 => [2,0],
        ?4 => [0,1], ?5 => [1,1], ?6 => [2,1],
        ?7 => [0,2], ?8 => [1,2], ?9 => [2,2],
                     ?0 => [1,3], ?* => [2,3] }

def metric(string)
  string.enum_for(:each_byte).map { |b| POS[b] }.
         enum_for(:each_cons, 2).inject(0) { |sum, ((x1,y1), (x2, y2))|
    # 1-norm
    # sum + (x1-x2).abs + (y1-y2).abs

    # 2-norm
    sum + Math.sqrt((x1-x2)**2 + (y1-y2)**2)
  }
end

def entries(time)
  return []  if time <= 0

  min, sec = time.divmod(60)
  entries = []

  # seconds only
  entries << "%d*" % [time]                 if time < 100

  # usual time format
  entries << "%d%02d*" % [min, sec]

  # more than 60 seconds
  entries << ("%d%02d*" % [min-1, sec+60])  if min > 1 && sec < 40

  entries
end

1.upto(999) { |time|
  entries = (-FUZZ..FUZZ).map { |offset| entries(time + offset) }.flatten

  # Sort by movement length, then by keypresses.
  quickest = entries.sort_by { |s| [metric(s), s.size] }.first
  puts "%3d (%02d:%02d): %s" % [time, time.divmod(60), quickest].flatten
}
