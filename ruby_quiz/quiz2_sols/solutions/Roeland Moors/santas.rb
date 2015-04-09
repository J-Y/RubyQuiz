# list of persons
$list = []

# generate list of candidates for santas
def get_candidates(person)
    cans = []
    $list.each do |p|
        cans.push p unless
            (p == person) ||
            (p['last'] == person['last']) ||
            (p['santa'] != -1)
    end
    cans
end

# get persons
while input = gets
    person = Hash.new
    person['first'], person['last'], person['mail'] = input.split
    person['santa'] = -1
    $list.push person
end

# seek santa
def seek_santa
    index = 0
    wrong = false
    $list.each do |person|
        candidates = get_candidates(person)
        wrong = true if candidates.length == 0
        return wrong if wrong
        r = rand(candidates.length)
        c = candidates[r]
        $list.find { |p| p == c }['santa'] = index
        index += 1
    end
    wrong
end

print '.' while !seek_santa
puts '.'

# display solution
$list.each do |person|
    s = $list[person['santa']]
    puts "#{person['first']} #{person['last']} -> #{s['first']} #{s['last']}"
end
