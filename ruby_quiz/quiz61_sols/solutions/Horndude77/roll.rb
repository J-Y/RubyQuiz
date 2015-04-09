$searches = [
    [/\(\d*\)/, lambda{|m| m[1..-2]}],
    [/^d/, lambda{|m| "1d"}],
    [/d%/, lambda{|m| "d100"}],
    [/(\+|-|\*|\/|\()d\d+/, lambda{|m| m[0..0]+'1'+m[1..-1]}],
    [/\d+d\d+/, lambda{|m| dice(*m.split('d').map {|i|i.to_i}) }],
    [/\d+(\*|\/)\d+/, lambda{|m| eval m}],
    [/\d+(\+|-)\d+/, lambda{|m| eval m}]
]
def parse(to_parse)
    s = to_parse
    while(s =~ /d|\+|-|\*|\/|\(|\)/)
        $searches.each do |search|
            if(s =~ search[0]) then
                s = s.sub(search[0], &search[1])
                break
            end
        end
    end
    s
end

def dice(times, sides)
    Array.new(times){rand(sides)+1}.inject(0) {|s,i|s+i}
end

srand
string = ARGV[0]
(puts "usage: #{$0} <string> [<iterations>]"; exit) if !string
(ARGV[1] || 1).to_i.times { print parse(string), ' ' }
