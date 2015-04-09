salesperson = customer = sortcode = "(undefined)"

$, = ";"

IO.readlines("period2-2002.txt").each { |line|
  case line 
  when /  Salesperson  (.*)/
    salesperson = $1
  when /  Customer  (.*)/
    customer = $1
  when /  SA Sort Code  (.*)/
    sortcode = $1
  when /^[0-9A-Z][0-9A-Z.-]+ .*\d+  .*\d+  /
    name, numbers = line[0..41], line[41..-1]

    numbers.gsub! ',', ''
    numbers.gsub! '%%%+', '0'

    print salesperson, customer, sortcode,
          *(name.strip.split(/  +/) + numbers.split(/ (?: +|(?=[-\d]))/))
  end
}
