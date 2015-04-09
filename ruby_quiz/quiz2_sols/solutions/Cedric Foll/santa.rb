#!/usr/bin/ruby

class Friends
        attr_reader :email, :family, :nb
        def initialize
                @email = Hash.new
                @members=0
                @nb = []
        end
        def add (first_name,family_name,mail)
                @email[mail] = family_name
                @nb[@members] = mail
                @members += 1
        end
end
# compute all permutation in a list
def permute(items, perms=[], res=[])
    unless items.length > 0
        res << perms
    else
        for i in items
            newitems = items.dup
            newperms = perms.dup
            newperms.unshift(newitems.delete(i))
            permute(newitems, newperms,res)
        end
    end
    return res
end

friends = Friends.new
while line = gets
        friends.add(*line.split(' '))
end
perms = permute(friends.email.keys)
perms.reject!{|tab|
        res = false
        for i in 0..tab.length-1
                if friends.email[tab[i]] == friends.email[friends.nb[i]]
                        # same family
                        res = true
                end
        end
        res
}
res = perms[rand(perms.length)]
for i in 0..res.length-1
        puts "#{friends.nb[i]} -> #{res[i]}"
end
